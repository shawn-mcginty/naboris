let () = Random.init (int_of_float (Unix.gettimeofday () *. 1000.0))

let generateSessionId () =
  Random.bits () |> string_of_int |> Digest.string |> Digest.to_hex

let sign secret sid =
  let hmac = Digestif.hmaci_string
    Digestif.sha256
    ~key:secret
    (fun f -> f sid)
  in
  sid ^ "." ^ Digestif.to_hex Digestif.sha256 hmac

let unsign secret signedSid = match String.split_on_char '.' signedSid with
  | [sid; _hash] ->
    if sign secret sid = signedSid then
      Some sid
    else
      None
  | _ -> None

let startSession req res data =
  let newSessionId = generateSessionId () |> sign (Req.secret req) in

  let req2 = Req.setSessionData (Some (Session.create newSessionId data)) req in
  let res2 = Res.setSessionCookies newSessionId (Req.sidKey req2) (Req.maxAge req2) res in
  (req2, res2, newSessionId)

let resumeSession (serverConfig : 'sessionData ServerConfig.t) req =
  match ServerConfig.sessionConfig serverConfig with
  | None -> Lwt.return req
  | Some sessionConfig ->
    let sid = match Cookie.sessionIdOfReq req with
      | Some signedSid -> unsign (Req.secret req) signedSid
      | None -> None
    in
    let%lwt maybeSessionData = sessionConfig.getSession sid in
    let req2 = Req.setSessionData maybeSessionData req in
    Lwt.return req2

let removeSession req res = Res.setSessionCookies "" (Req.sidKey req) 0 res 