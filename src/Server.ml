module Req = Req
module Res = Res
module Router = Router

exception UnknownError of string

type unknown_error = UnknownError

type httpaf_error =
  [ `Internal_server_error | `Bad_gateway | `Bad_request | `Exn of exn ]

type httpaf_error_handler =
  ?request:Httpaf.Request.t ->
  httpaf_error ->
  (Httpaf.Headers.t -> [ `write ] Httpaf.Body.t) ->
  unit

let supplied_error_handler handler (_client_addr : 'a) ?request
    (error : httpaf_error) start_response =
  match request with
  | None ->
      let response_body = start_response Httpaf.Headers.empty in
      let _ = Httpaf.Body.write_string response_body "Unknown Error" in
      Httpaf.Body.close_writer response_body
  | Some (httpaf_req : Httpaf.Request.t) ->
      let target = httpaf_req.target in
      let meth = Method.of_httpaf_method httpaf_req.meth in
      let route = Router.generate_route target meth in
      let real_exn =
        match error with
        | `Exn e -> e
        | `Internal_server_error -> UnknownError "Internal server error"
        | `Bad_gateway -> UnknownError "Bad gateway"
        | `Bad_request -> UnknownError "Bad request"
      in

      Lwt.async (fun () ->
          let%lwt headers, body = handler real_exn route in
          let httpaf_headers = Httpaf.Headers.of_list headers in
          let response_body = start_response httpaf_headers in
          let _ = Httpaf.Body.write_string response_body body in
          let _ = Httpaf.Body.close_writer response_body in
          Lwt.return_unit)

let build_connection_handler server_config =
  let request_handler _client_addr reqd =
    let request = Httpaf.Reqd.request reqd in
    let target = request.target in
    let meth = Method.of_httpaf_method request.meth in
    let route = Router.generate_route target meth in

    Lwt.async (fun () ->
        let raw_req =
          Req.from_reqd reqd
            (ServerConfig.session_config server_config)
            (ServerConfig.static_cache_control server_config)
            (ServerConfig.static_last_modified server_config)
            (ServerConfig.etag server_config)
        in
        let%lwt req = SessionManager.resume_session server_config raw_req in
        let%lwt _ =
          match ServerConfig.middlewares server_config with
          | [] ->
              ServerConfig.route_request server_config route req
                (Res.default ())
          | [ single_middleware ] ->
              single_middleware
                (ServerConfig.route_request server_config)
                route req (Res.default ())
          | _multiple_middlewares ->
              let full_handler =
                ServerConfig.middlewares server_config
                |> List.rev
                |> List.fold_left
                     (fun next current -> current next)
                     (ServerConfig.route_request server_config)
              in

              full_handler route req (Res.default ())
        in
        Lwt.return_unit)
  in

  let default_error_handler _client_address ?request:_ error start_response =
    let msg =
      match error with
      | `Exn e -> Printexc.to_string e
      | `Internal_server_error -> "Internal server error"
      | `Bad_gateway -> "Bad gateway"
      | `Bad_request -> "Bad request"
    in
    let headers =
      [
        ("Content-type", "plain/text");
        ("Content-length", msg |> String.length |> string_of_int);
      ]
    in
    let response_body = start_response (Httpaf.Headers.of_list headers) in
    let _ = Httpaf.Body.write_string response_body msg in
    Httpaf.Body.close_writer response_body
  in

  let error_handler : Unix.sockaddr -> httpaf_error_handler =
    match ServerConfig.error_handler server_config with
    | None -> default_error_handler
    | Some handler -> supplied_error_handler handler
  in

  Httpaf_lwt_unix.Server.create_connection_handler
    ?config:(ServerConfig.httpaf_config server_config)
    ~request_handler ~error_handler
