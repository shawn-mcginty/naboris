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
  middlewares: list(Middleware.t('sessionData)),
  staticCacheControl: option(string),
  staticLastModified: bool,
  etag: option(Etag.strength),
};

let default = {
  onListen: () => (),
  errorHandler: None,
  routeRequest: (_route, req, res) => {
    res |> Res.status(404) |> Res.raw(req, "Resource not found");
  },
  sessionConfig: None,
  httpAfConfig: None,
  middlewares: [],
  staticCacheControl: Some("public, max-age=0"),
  staticLastModified: true,
  etag: Some(`Weak),
};

let sessionConfig = conf => conf.sessionConfig;

let errorHandler = conf => conf.errorHandler;

let routeRequest = conf => conf.routeRequest;

let onListen = conf => conf.onListen;

let create = () => default;

let setOnListen = (onListenFn, conf) => {...conf, onListen: onListenFn};

let setRequestHandler = (reqHandlerFn, conf) => {
  ...conf,
  routeRequest: reqHandlerFn,
};

let setErrorHandler = (errHandlerFn, conf) => {
  ...conf,
  errorHandler: Some(errHandlerFn),
};

let setHttpAfConfig = (httpAfConfig, conf) => {
  ...conf,
  httpAfConfig: Some(httpAfConfig),
};

let addMiddleware = (middleware, conf) => {
  ...conf,
  middlewares: List.append(conf.middlewares, [middleware]),
};

let middlewares = conf => conf.middlewares;

let rec matchPaths = (matcher, path) =>
  switch (matcher, path) {
  | ([x], [y, ...rest]) when x == y => Some(rest)
  | ([x, ...restMatcher], [y, ...restPath]) when x == y =>
    matchPaths(restMatcher, restPath)
  | _ => None
  };

let addStaticMiddleware = (pathPrefix, publicPath, conf) =>
  conf
  |> addMiddleware((next, route, req, res) =>
       switch (Route.meth(route), Route.path(route)) {
       | (Method.GET, path) =>
         switch (matchPaths(pathPrefix, path)) {
         | Some(remainingPath) =>
           Res.static(publicPath, remainingPath, req, res)
         | _ => next(route, req, res)
         }

       | _ => next(route, req, res)
       }
     );

let setSessionConfig =
    (~maxAge=2592000, ~sidKey="nab.sid", ~secret="please set to a secure value", getSessionFn, conf) => {
  let sessionConfig: SessionConfig.t('sessionData) = {
    getSession: getSessionFn,
    maxAge,
    sidKey,
    secret,
  };
  {...conf, sessionConfig: Some(sessionConfig)};
};

let staticCacheControl = conf => conf.staticCacheControl;

let setStaticCacheControl = (cacheControl, conf) => {...conf, staticCacheControl: cacheControl};

let staticLastModified = conf => conf.staticLastModified;

let setStaticLastModified = (staticLastModified, conf) => {...conf, staticLastModified };

let etag = conf => conf.etag;

let setEtag = (etag, conf: t('sessionData)) => {...conf, etag};

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