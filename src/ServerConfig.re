type sessionConfig('sessionData) = {
  onRequest: option(string) => Lwt.t(option(Session.t('sessionData))),
};

type httpAfConfig = {
  read_buffer_size: int,
  request_body_buffer_size: int,
  response_buffer_size: int,
  response_body_buffer_size: int,
};

type t('sessionData) = {
  onListen: unit => unit,
  routeRequest: (Route.t, Req.t('sessionData), Res.t) => Lwt.t(unit),
  sessionConfig: option(sessionConfig('sessionData)),
  errorHandler: option(ErrorHandler.t),
  httpAfConfig: option(httpAfConfig),
  middlewares: list(Middleware.t('sessionData))
};

let default = {
  onListen: () => (),
  errorHandler: Some((
    _client_address,
    _request,
    error,
    start_response) => {
    let msg = switch (error) {
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
  }),
  routeRequest: (_route, req, res) => {
    res |> Res.status(404)
      |> Res.raw(req, "Resource not found");
    Lwt.return_unit;
  },
  sessionConfig: None,
  httpAfConfig: None,
  middlewares: [],
};

let create = () => default;

let setOnListen = (onListenFn, conf) => { ...conf, onListen: onListenFn };

let setRequestHandler = (reqHandlerFn, conf) => { ...conf, routeRequest: reqHandlerFn };

let setErrorHandler = (errHandlerFn, conf) => { ...conf, errorHandler: errHandlerFn };

let setHttpAfConfig = (httpAfConfig, conf) => { ...conf, httpAfConfig };

let addMiddleware = (middleware, conf) => { ...conf, middlewares: List.append(conf.middlewares, [ middleware ]) }

let toHttpAfConfig = (conf: t('sessionData)): option(Httpaf.Config.t) =>
  switch (conf.httpAfConfig) {
  | None => None
  | Some(httpConf) =>
    let {
      read_buffer_size,
      request_body_buffer_size,
      response_buffer_size,
      response_body_buffer_size,
    } = httpConf;
    Some({
      read_buffer_size,
      request_body_buffer_size,
      response_buffer_size,
      response_body_buffer_size,
    });
  };