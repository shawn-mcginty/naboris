module Req = Req;
module Res = Res;
module Router = Router;

exception UnknownError(string);

type unknownError =
  | UnknownError;

let buildConnectionHandler = (serverConfig: ServerConfig.t('sessionData)) => {
  let request_handler =
      (_client_address: Unix.sockaddr, request_descriptor: Httpaf.Reqd.t) => {
    let request: Httpaf.Request.t = Httpaf.Reqd.request(request_descriptor);
    let target = request.target;
    let meth = Method.ofHttpAfMethod(request.meth);
    let route = Router.generateRoute(target, meth);

    Lwt.async(() => {
      let rawReq =
        Req.fromReqd(
          request_descriptor,
          ServerConfig.sessionConfig(serverConfig),
          ServerConfig.staticCacheControl(serverConfig),
          ServerConfig.staticLastModified(serverConfig),
        );

      let%lwt req = SessionManager.resumeSession(serverConfig, rawReq);
      let%lwt _ = switch (ServerConfig.middlewares(serverConfig)) {
        | [] =>
          ServerConfig.routeRequest(serverConfig, route, req, Res.default());
        | [oneMiddleware] =>
          oneMiddleware(
            ServerConfig.routeRequest(serverConfig),
            route,
            req,
            Res.default(),
          )
        | _moreThanOneMiddleware =>
          let fullHandler =
            ServerConfig.middlewares(serverConfig)
            |> List.rev
            |> List.fold_left(
              (next: RequestHandler.t('a), current) => current(next),
              ServerConfig.routeRequest(serverConfig),
            );
          
          fullHandler(route, req, Res.default());
      }
      Lwt.return_unit;
    });
  };

  let default_error_handler =
      (_client_address: Unix.sockaddr, ~request as _=?, error, start_response) => {
    let msg =
      switch (error) {
      | `Exn(e) => Printexc.to_string(e)
      | `Internal_server_error => "Internal server error"
      | `Bad_gateway => "Bad gateway"
      | `Bad_request => "Bad request"
      };
    let headers = [
      ("Content-type", "plain/text"),
      ("Conent-length", string_of_int(String.length(msg))),
    ];
    let response_body = start_response(Httpaf.Headers.of_list(headers));
    Httpaf.Body.write_string(response_body, msg);
    Httpaf.Body.close_writer(response_body);
  };

  let error_handler =
    switch (ServerConfig.errorHandler(serverConfig)) {
    | None => default_error_handler
    | Some(handler) => (
        (
          _client_address: Unix.sockaddr,
          ~request=?,
          error: Httpaf.Server_connection.error,
          start_response,
        ) =>
          switch (request) {
          | None =>
            let response_body = start_response(Httpaf.Headers.empty);
            Httpaf.Body.write_string(response_body, "Unknown Error");
            Httpaf.Body.close_writer(response_body);
          | Some((httpafReq: Httpaf.Request.t)) =>
            let target = httpafReq.target;
            let meth = Method.ofHttpAfMethod(httpafReq.meth);
            let route = Router.generateRoute(target, meth);

            let realExn =
              switch (error) {
              | `Exn(e) => e
              | `Internal_server_error =>
                UnknownError("Internal server error")
              | `Bad_gateway => UnknownError("Bad gateway")
              | `Bad_request => UnknownError("Bad request")
              };

            Lwt.async(() => {
              let%lwt (headers, body) = handler(realExn, route);
              let response_body = start_response(Httpaf.Headers.of_list(headers));
              Httpaf.Body.write_string(response_body, body);
              Httpaf.Body.close_writer(response_body);
              Lwt.return_unit;
            });
          }
      )
    };

  Httpaf_lwt_unix.Server.create_connection_handler(
    ~config=?ServerConfig.httpAfConfig(serverConfig),
    ~request_handler,
    ~error_handler,
  );
};