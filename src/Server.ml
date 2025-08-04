module Req = Req
module Res = Res
module Router = Router

exception UnknownError of string

type unknownError =
  | UnknownError

let buildConnectionHandler (serverConfig : 'sessionData ServerConfig.t) =
  let request_handler
      (_client_address : Unix.sockaddr) (request_descriptor : Httpaf.Reqd.t) =
    let request : Httpaf.Request.t = Httpaf.Reqd.request request_descriptor in
    let target = request.target in
    let meth = Method.ofHttpAfMethod request.meth in
    let route = Router.generateRoute target meth in

    Lwt.async (fun () ->
      let rawReq =
        Req.fromReqd
          request_descriptor
          (ServerConfig.sessionConfig serverConfig)
          (ServerConfig.staticCacheControl serverConfig)
          (ServerConfig.staticLastModified serverConfig)
          (ServerConfig.etag serverConfig)
      in

      let%lwt req = SessionManager.resumeSession serverConfig rawReq in
      let%lwt _ = match ServerConfig.middlewares serverConfig with
        | [] ->
          ServerConfig.routeRequest serverConfig route req (Res.default ())
        | [oneMiddleware] ->
          oneMiddleware
            (ServerConfig.routeRequest serverConfig)
            route
            req
            (Res.default ())
        | _moreThanOneMiddleware ->
          let fullHandler =
            ServerConfig.middlewares serverConfig
            |> List.rev
            |> List.fold_left
              (fun (next : 'a RequestHandler.t) current -> current next)
              (ServerConfig.routeRequest serverConfig)
          in
          
          fullHandler route req (Res.default ())
      in
      Lwt.return_unit)
  in

  let default_error_handler
      (_client_address : Unix.sockaddr) ?request:_ error start_response =
    let msg =
      match error with
      | `Exn e -> Printexc.to_string e
      | `Internal_server_error -> "Internal server error"
      | `Bad_gateway -> "Bad gateway"
      | `Bad_request -> "Bad request"
    in
    let headers = [
      ("Content-type", "plain/text");
      ("Conent-length", string_of_int (String.length msg));
    ] in
    let response_body = start_response (Httpaf.Headers.of_list headers) in
    Httpaf.Body.write_string response_body msg;
    Httpaf.Body.close_writer response_body
  in

  let error_handler =
    match ServerConfig.errorHandler serverConfig with
    | None -> default_error_handler
    | Some handler -> (fun
        (_client_address : Unix.sockaddr)
        ?request
        (error : Httpaf.Server_connection.error)
        start_response ->
          match request with
          | None ->
            let response_body = start_response Httpaf.Headers.empty in
            Httpaf.Body.write_string response_body "Unknown Error";
            Httpaf.Body.close_writer response_body
          | Some (httpafReq : Httpaf.Request.t) ->
            let target = httpafReq.target in
            let meth = Method.ofHttpAfMethod httpafReq.meth in
            let route = Router.generateRoute target meth in

            let realExn =
              match error with
              | `Exn e -> e
              | `Internal_server_error ->
                UnknownError "Internal server error"
              | `Bad_gateway -> UnknownError "Bad gateway"
              | `Bad_request -> UnknownError "Bad request"
            in

            Lwt.async (fun () ->
              let%lwt (headers, body) = handler realExn route in
              let response_body = start_response (Httpaf.Headers.of_list headers) in
              Httpaf.Body.write_string response_body body;
              Httpaf.Body.close_writer response_body;
              Lwt.return_unit))
  in

  Httpaf_lwt_unix.Server.create_connection_handler
    ?config:(ServerConfig.httpAfConfig serverConfig)
    ~request_handler
    ~error_handler 