type t = {
  status : int;
  headers : (string * string) list;
  closed : bool;
  exn : exn option;
}

let default () = { status = 200; headers = []; closed = false; exn = None }

let create_httpaf_response res =
  Httpaf.Response.create
    ~headers:(Httpaf.Headers.of_list res.headers)
    (Httpaf.Status.of_code res.status)

let add_header header res =
  let key, value = header in
  { res with headers = (String.lowercase_ascii key, value) :: res.headers }

let add_header_if_none header res =
  let key, _ = header in
  let existing =
    List.fold_left
      (fun exists h ->
        match exists with
        | true -> true
        | false ->
            let k, _ = h in
            k = key)
      false res.headers
  in

  match existing with true -> res | false -> add_header header res

let status status res = { res with status }

let close_response res = { res with closed = true }

let add_date_header res =
  let now = Unix.time () |> DateUtils.format_for_headers in
  add_header_if_none ("Date", now) res

let add_etag_header entity req res =
  match Req.response_etag req with
  | None -> res
  | Some `Weak -> add_header_if_none ("Etag", Etag.weak_of_string entity) res
  | Some `Strong -> add_header_if_none ("Etag", Etag.of_string entity) res

let raw req body res =
  let res_with_headers =
    add_header_if_none
      ("Content-length", String.length body |> string_of_int)
      res
    |> add_header_if_none ("Connection", "keep-alive")
    |> add_date_header |> add_etag_header body req
  in
  let response = create_httpaf_response res_with_headers in
  let reqd = Req.reqd req in

  let response_body = Httpaf.Reqd.respond_with_streaming reqd response in
  let _ = Httpaf.Body.write_string response_body body in
  let _ = Httpaf.Body.close_writer response_body in
  close_response res_with_headers |> Lwt.return

let text req body res =
  add_header_if_none ("Content-Type", "text/plain") res |> raw req body

let json req body res =
  add_header_if_none ("Content-Type", "application/json") res |> raw req body

let html req html_body res =
  add_header_if_none ("Content-Type", "text/html") res |> raw req html_body

let stream_file_contents_to_body full_file_path res_body =
  let read_only_flags = [ Unix.O_RDONLY ] in
  let read_only_perm = 444 in
  let%lwt fd =
    Lwt_unix.openfile full_file_path read_only_flags read_only_perm
  in
  let channel = Lwt_io.of_fd fd ~mode:Lwt_io.Input in
  let buffer_size = Lwt_io.default_buffer_size () in
  let rec pipe_body ~count ch body =
    let%lwt chunk = Lwt_io.read ~count ch in
    let _ = Httpaf.Body.write_string body chunk in
    match String.length chunk with
    | x when x < count -> Lwt.return_unit
    | _ -> pipe_body ~count ch body
  in

  Lwt.finalize
    (fun () -> pipe_body ~count:buffer_size channel res_body)
    (fun () ->
      let _ = Httpaf.Body.close_writer res_body in
      Lwt_io.close channel)

let add_cache_control req res =
  match Req.static_cache_control req with
  | None -> res
  | Some cache_control ->
      add_header_if_none ("Cache-Control", cache_control) res

let add_last_modified req (stats : Unix.stats) res =
  let modified_time = DateUtils.format_for_headers stats.st_mtime in

  match Req.static_last_modified req with
  | true -> add_header_if_none ("Last-Modified", modified_time) res
  | false -> res

let add_file_etag_headers req full_file_path res =
  match Req.response_etag req with
  | None -> Lwt.return res
  | Some `Weak ->
      let%lwt etag = Etag.weak_of_path full_file_path in
      add_header_if_none ("Etag", etag) res |> Lwt.return
  | Some `Strong ->
      let%lwt etag = Etag.of_file_path full_file_path in
      add_header_if_none ("Etag", etag) res |> Lwt.return

let add_static_headers req full_file_path (stats : Unix.stats) res =
  let size = stats.st_size in

  add_header_if_none ("Content-Type", MimeTypes.of_file_name full_file_path) res
  |> add_header_if_none ("Content-Length", string_of_int size)
  |> add_cache_control req
  |> add_last_modified req stats
  |> add_date_header
  |> add_file_etag_headers req full_file_path

let static base_path path_list req res =
  let full_file_path = Static.get_file_path base_path path_list in
  let%lwt exists = Lwt_unix.file_exists full_file_path in
  match exists with
  | true ->
      let%lwt stats = Lwt_unix.stat full_file_path in
      let%lwt res_with_headers =
        add_static_headers req full_file_path stats res
      in

      let response = create_httpaf_response res_with_headers in
      let reqd = Req.reqd req in
      let response_body = Httpaf.Reqd.respond_with_streaming reqd response in

      let%lwt () = stream_file_contents_to_body full_file_path response_body in
      res_with_headers |> close_response |> Lwt.return
  | false ->
      let res_with_headers =
        status 404 res
        |> add_header_if_none ("Content-Length", "9")
        |> add_header_if_none ("Connection", "keep-alive")
      in
      let response = create_httpaf_response res_with_headers in
      let reqd = Req.reqd req in
      let response_body = Httpaf.Reqd.respond_with_streaming reqd response in
      let _ = Httpaf.Body.write_string response_body "Not found" in
      let _ = Httpaf.Body.close_writer response_body in
      res_with_headers |> close_response |> Lwt.return

let set_session_cookies new_sid sid_key max_age res =
  let set_cookie_key = "Set-Cookie" in
  let max_age_str = string_of_int max_age in
  add_header_if_none
    (set_cookie_key, sid_key ^ "=" ^ new_sid ^ "; Max-Age=" ^ max_age_str ^ "; SameSite=Strict")
    res

let redirect path req res =
  status 302 res |> add_header_if_none ("Location", path) |> text req "Found"

let report_error exn req res =
  let reqd = Req.reqd req in
  let _ = Httpaf.Reqd.report_exn reqd exn in
  let exn_res = { res with exn = Some exn } in
  Lwt.return exn_res

let write_channel req res =
  let reqd = Req.reqd req in
  let res_with_headers =
    add_header_if_none ("Transfer-encoding", "chunked") res
    |> add_header_if_none ("Connection", "keep-alive")
  in

  let response_body =
    create_httpaf_response res_with_headers
    |> Httpaf.Reqd.respond_with_streaming ~flush_headers_immediately:true reqd
  in

  let on_write bytes off len =
    let _ = Httpaf.Body.write_bigstring ~off ~len response_body bytes in
    Lwt.return len
  in

  let resp_promise, resp_resolver = Lwt.task () in

  let close () =
    let _ = Httpaf.Body.close_writer response_body in
    let _ = Lwt.wakeup resp_resolver (close_response res_with_headers) in
    Lwt.return_unit
  in

  let write_ch = Lwt_io.make ~close ~mode:Output on_write in
  (write_ch, resp_promise)
