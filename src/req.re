type t('sessionData) = {
  requestDescriptor: Httpaf.Reqd.t,
  session: option(Session.t('sessionData)),
};

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

let fromReqd = (reqd, maybeSessionHandler) => {
  let defaultReq = {requestDescriptor: reqd, session: None};
  switch (maybeSessionHandler) {
  | None => defaultReq
  | Some(_sessionHandler) =>
    let request = Httpaf.Reqd.request(reqd);
    switch (Httpaf.Headers.get(request.headers, "Cookie")) {
    | None => defaultReq
    | Some(_cookie) => defaultReq
    };
  };
};

let getSessionData = req => {
  switch (req.session) {
  | None => None
  | Some(session) => Some(session.data)
  };
};

let setSessionData = (maybeSession, req) => {
  {...req, session: maybeSession};
};