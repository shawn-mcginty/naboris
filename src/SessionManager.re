open Lwt.Infix;

let startSession = (req, res, data) => {
  let nowFloat = Unix.time();
  let nowStr = string_of_float(nowFloat);
  Random.init(int_of_float(nowFloat));
  let hash1 = Random.bits() |> string_of_int |> Digest.string |> Digest.to_hex;
  let hash2 = Digest.string(nowStr) |> Digest.to_hex;
  let hash3 = Random.bits() |> string_of_int |> Digest.string |> Digest.to_hex;
  let hash4 = Random.bits() |> string_of_int |> Digest.string |> Digest.to_hex;
  let newSessionId = hash1 ++ hash2 ++ hash3 ++ hash4;

  let req2 = Req.setSessionData(Some({id: newSessionId, data}), req);
  let res2 = Res.setSessionCookies(newSessionId, res);
  (req2, res2);
};

let resumeSession = (serverConfig: ServerConfig.t('sessionData), req) => {
  switch (serverConfig.sessionConfig) {
  | None => Lwt.return(req)
  | Some(sessionConfig) =>
    let sid = Cookie.sessionIdOfReq(req);
    sessionConfig.onRequest(sid)
    >>= (
      maybeSessionData => {
        let req2 = Req.setSessionData(maybeSessionData, req);
        Lwt.return(req2);
      }
    );
  };
};