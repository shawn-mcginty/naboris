let () = Random.init(int_of_float(Unix.gettimeofday() *. 1000.0));

let generateSessionId = () => {
  Random.bits() |> string_of_int |> Digest.string |> Digest.to_hex;
};

let sign = (secret, sid) => {
  let hmac = Digestif.hmaci_string(
    Digestif.sha256,
    ~key=secret,
    f => f(sid),
  );
  sid ++ "." ++ Digestif.to_hex(Digestif.sha256, hmac);
};

let unsign = (secret, signedSid) => switch(String.split_on_char('.', signedSid)) {
  | [sid, _hash] =>
    if (sign(secret, sid) == signedSid) {
      Some(sid)
    } else {
      None
    }
  | _ => None
};

let startSession = (req, res, data) => {
  let newSessionId = generateSessionId() |> sign(Req.secret(req));

  let req2 = Req.setSessionData(Some(Session.create(newSessionId, data)), req);
  let res2 = Res.setSessionCookies(newSessionId, Req.sidKey(req2), Req.maxAge(req2), res);
  (req2, res2, newSessionId);
};

let resumeSession = (serverConfig: ServerConfig.t('sessionData), req) => {
  switch (ServerConfig.sessionConfig(serverConfig)) {
  | None => Lwt.return(req)
  | Some(sessionConfig) =>
    let sid = switch (Cookie.sessionIdOfReq(req)) {
      | Some(signedSid) => unsign(Req.secret(req), signedSid);
      | None => None
    };
    let%lwt maybeSessionData = sessionConfig.getSession(sid);
    let req2 = Req.setSessionData(maybeSessionData, req);
    Lwt.return(req2);
  };
};

let removeSession = (req, res) => Res.setSessionCookies("", Req.sidKey(req), 0, res);