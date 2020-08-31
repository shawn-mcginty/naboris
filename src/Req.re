type t('sessionData) = {
  requestDescriptor: Httpaf.Reqd.t,
  session: option(Session.t('sessionData)),
  sidKey: string,
  maxAge: int,
  secret: string,
  staticCacheControl: option(string),
  staticLastModified: bool,
  responseEtag: option(Etag.strength),
};

let reqd = req => req.requestDescriptor;

let getHeader = (headerKey, req) =>
  switch (Httpaf.Reqd.request(req.requestDescriptor)) {
  | {headers, _} => Httpaf.Headers.get(headers, headerKey)
  };

let getBody = ({requestDescriptor, _}) => {
  let body = Httpaf.Reqd.request_body(requestDescriptor);
  let (bodyStream, pushToBodyStream) = Lwt_stream.create();

  let rec on_read = (bigstr, ~off as _, ~len as _) => {
    let str = Bigstringaf.to_string(bigstr);
    pushToBodyStream(Some(str));
    Httpaf.Body.schedule_read(body, ~on_read, ~on_eof);
  }
  and on_eof = () => pushToBodyStream(None);

  Httpaf.Body.schedule_read(body, ~on_read, ~on_eof);

  Lwt_stream.fold((a, b) => a ++ b, bodyStream, "");
};

let fromReqd = (reqd, sessionConfig, staticCacheControl, staticLastModified, responseEtag) => {
  let sidKey = SessionConfig.sidKey(sessionConfig);
  let maxAge = SessionConfig.maxAge(sessionConfig);
  let secret = SessionConfig.secret(sessionConfig);
  let defaultReq = {requestDescriptor: reqd, session: None, sidKey, maxAge, secret, staticCacheControl, staticLastModified, responseEtag};
  defaultReq;
};

let getSessionData = req => {
  switch (req.session) {
  | None => None
  | Some(session) => Some(Session.data(session))
  };
};

let setSessionData = (maybeSession, req) => {
  {...req, session: maybeSession};
};

let sidKey = req => req.sidKey;

let maxAge = req => req.maxAge;

let secret = req => req.secret;

let staticCacheControl = req => req.staticCacheControl;

let staticLastModified = req => req.staticLastModified;

let responseEtag = req => req.responseEtag;