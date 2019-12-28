module Req = Req;
module Res = Res;
module Router = Router;

open Lwt.Infix;

let buildConnectionHandler = (serverConfig: ServerConfig.t('sessionData)) => {
  let request_handler =
      (_client_address: Unix.sockaddr, request_descriptor: Httpaf.Reqd.t) => {
    let request: Httpaf.Request.t = Httpaf.Reqd.request(request_descriptor);
    let target = request.target;
    let meth = Method.ofHttpAfMethod(request.meth);
    let route = Router.generateRoute(target, meth);

    Lwt.async(() => {
      let rawReq =
        Req.fromReqd(request_descriptor, serverConfig.sessionConfig);

      SessionManager.resumeSession(serverConfig, rawReq)
      >>= (
        req => {
          serverConfig.routeRequest(route, req, Res.default());
        }
      );
    });
  };

  let error_handler =
      (
        _client_address: Unix.sockaddr,
        ~request as _=?,
        _error,
        start_response,
      ) => {
    let response_body = start_response(Httpaf.Headers.empty);
    Httpaf.Body.write_string(response_body, "Unknown Error");
    Httpaf.Body.close_writer(response_body);
  };

  Httpaf_lwt_unix.Server.create_connection_handler(
    ~config=?None,
    ~request_handler,
    ~error_handler,
  );
};