let () = Random.init (int_of_float (Unix.gettimeofday () *. 1000.0))

let generate_session_id () =
  Random.bits () |> string_of_int |> Digest.string |> Digest.to_hex

let sign secret sid =
  let hmac =
    Digestif.hmaci_string Digestif.sha256 ~key:secret (fun f -> f sid)
  in
  sid ^ "." ^ Digestif.to_hex Digestif.sha256 hmac

let unsign secret signed_sid =
  match String.split_on_char '.' signed_sid with
  | [ sid; _hash ] -> (
      match sign secret sid = signed_sid with true -> Some sid | false -> None )
  | _ -> None

let start_session req res data =
  let sign_with_secret = sign (Req.secret req) in
  let new_session_id = generate_session_id () |> sign_with_secret in
  let req2 =
    Req.set_session_data (Some (Session.make new_session_id data)) req
  in
  let res2 =
    Res.set_session_cookies new_session_id (Req.sid_key req2) (Req.max_age req2)
      res
  in
  (req2, res2, new_session_id)

let resume_session server_config req =
  match ServerConfig.session_config server_config with
  | None -> Lwt.return req
  | Some session_config ->
      let sid =
        match Cookie.session_id_of_req req with
        | Some signed_sid -> unsign (Req.secret req) signed_sid
        | None -> None
      in
      let%lwt maybe_session_data = session_config.get_session sid in
      let req2 = Req.set_session_data maybe_session_data req in
      Lwt.return req2

let remove_session req res = Res.set_session_cookies "" (Req.sid_key req) 0 res
