type 'sessionData t = {
  request_descriptor : Httpaf.Reqd.t;
  session : 'sessionData Session.t option;
  sid_key : string;
  max_age : int;
  secret : string;
  static_cache_control : string option;
  static_last_modified : bool;
  response_etag : Etag.strength option;
}

let reqd req = req.request_descriptor

let get_header header_key req =
  match Httpaf.Reqd.request req.request_descriptor with
  | { headers; _ } -> Httpaf.Headers.get headers header_key

let get_body req =
  let { request_descriptor; _ } = req in
  let body = Httpaf.Reqd.request_body request_descriptor in
  let body_stream, push_to_body_stream = Lwt_stream.create () in
  let rec on_read bigstr ~off:_ ~len:_ =
    let str = Bigstringaf.to_string bigstr in
    let _ = push_to_body_stream (Some str) in
    Httpaf.Body.schedule_read body ~on_read ~on_eof
  and on_eof () = push_to_body_stream None in

  let _ = Httpaf.Body.schedule_read body ~on_read ~on_eof in

  Lwt_stream.fold (fun a b -> a ^ b) body_stream ""

let from_reqd reqd (session_config : 'sessionData SessionConfig.t option)
    static_cache_control static_last_modified response_etag =
  let sid_key = SessionConfig.sid_key session_config in
  let max_age = SessionConfig.max_age session_config in
  let secret = SessionConfig.secret session_config in
  let default_req : 'sessionData t =
    {
      request_descriptor = reqd;
      session : 'sessionData Session.t option = None;
      sid_key;
      max_age;
      secret;
      static_cache_control;
      static_last_modified;
      response_etag;
    }
  in
  default_req

let get_session_data req =
  match req.session with
  | None -> None
  | Some session -> Some (Session.data session)

let set_session_data maybe_session req = { req with session = maybe_session }

let sid_key req = req.sid_key

let max_age req = req.max_age

let secret req = req.secret

let static_cache_control req = req.static_cache_control

let static_last_modified req = req.static_last_modified

let response_etag req = req.response_etag
