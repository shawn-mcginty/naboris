type httpAfConfig = {
  read_buffer_size: int,
  request_body_buffer_size: int,
  response_buffer_size: int,
  response_body_buffer_size: int,
};

type t('sessionData) = {
  onListen: unit => unit,
  routeRequest: (Route.t, Req.t('sessionData), Res.t) => Lwt.t(Res.t),
  sessionConfig: option(SessionConfig.t('sessionData)),
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
  },
  sessionConfig: None,
  httpAfConfig: None,
  middlewares: [],
};

let sessionConfig = conf => conf.sessionConfig;

let errorHandler = conf => conf.errorHandler;

let routeRequest = conf => conf.routeRequest;

let onListen = conf => conf.onListen;

let create = () => default;

let setOnListen = (onListenFn, conf) => { ...conf, onListen: onListenFn };

let setRequestHandler = (reqHandlerFn, conf) => { ...conf, routeRequest: reqHandlerFn };

let setErrorHandler = (errHandlerFn, conf) => { ...conf, errorHandler: Some(errHandlerFn) };

let setHttpAfConfig = (httpAfConfig, conf) => { ...conf, httpAfConfig: Some(httpAfConfig) };

let addMiddleware = (middleware, conf) => { ...conf, middlewares: List.append(conf.middlewares, [ middleware ]) }

let middlewares = conf => conf.middlewares;

let rec matchPaths = (matcher, path) => switch (matcher, path) {
  | ([x], [y, ...rest]) when x == y => Some(rest)
  | ([x, ...restMatcher], [y, ...restPath]) when x == y => matchPaths(restMatcher, restPath)
  | _ => None
};

let addStaticMiddleware = (pathPrefix, publicPath, conf) => conf
  |> addMiddleware((next, route, req, res) => switch (Route.meth(route), Route.path(route)) {
    | (Method.GET, path) => switch (matchPaths(pathPrefix, path)) {
      | Some(remainingPath) => Res.static(publicPath, remainingPath, req, res)
      | _ => next(route, req, res)
    }

    | _ => next(route, req, res)
  });

let setSessionConfig = (~maxAge=2592000, ~sidKey="nab.sid", getSessionFn, conf) => {
  let sessionConfig: SessionConfig.t('sessionData) = {
    getSession: getSessionFn,
    maxAge,
    sidKey,
  };
  { ...conf, sessionConfig: Some(sessionConfig) };
};

let httpAfConfig = (conf: t('sessionData)): option(Httpaf.Config.t) =>
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