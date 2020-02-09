type t('sessionData);

type httpAfConfig = {
  read_buffer_size: int,
  request_body_buffer_size: int,
  response_buffer_size: int,
  response_body_buffer_size: int,
};

/**
 Returns default config.  Used as the starting place to build the config.
 */
let create: unit => t('sessionData);

/**
 Create new config from [t('sessionData)] with the onListen function [unit => unit].

 [onListen] function is called once the server is created successfully.
 */
let setOnListen: (unit => unit, t('sessionData)) => t('sessionData);

/**
 Creates new config from [t('sessionData)] with sessionGetter function [option(string) => Lwt.t(option(Session.t('sessionData)))].

 [sessionGetter] function is called at the very beginning of each request/response lifecycle.
 Used to set session data into the [Req.t('sessionData)] for use later in the request/response lifecycle.

 [~maxAge] Optional param to set max age for session cookies in seconds (defaults to 30 days)
 [~sidKey] Optional param to set key for session cookies (defaults to ["nab.sid"])
 */
let setSessionConfig: (~maxAge: int=?, ~sidKey: string=?, option(string) => Lwt.t(option(Session.t('sessionData))), t('sessionData)) => t('sessionData);

/**
 Creates new config from [t('sessionData)] with requestHandler [(Route.t, Req.t('sessionData), Res.t) => Lwt.t(unit)].

 [requestHandler] is the main handler function for responding to incoming http requests.
 */
let setRequestHandler: ((Route.t, Req.t('sessionData), Res.t) => Lwt.t(unit), t('sessionData)) => t('sessionData);


/**
 Creates new config from [t('sessionData)] with errorHandler [ErrorHandler.t].
 */
let setErrorHandler: (ErrorHandler.t, t('sessionData)) => t('sessionData);

/**
 Creates new config from [t('sessionData)] with httpAfConfig [httpAfConfig].
 */
let setHttpAfConfig: (httpAfConfig, t('sessionData)) => t('sessionData);

/**
 Creates nwe config from [t('sessionData)] with the added middleware [Middleware.t('sessionData)].

 Middlewares are executed in the order they are added.  The final "middleware" is the [requestHandler].
 */
let addMiddleware: (Middleware.t('sessionData), t('sessionData)) => t('sessionData);

/**
 Creates a virtual path prefix [list(string)] and maps it to a local directory [string].

 Middlewares are executed in the order they are added.  The final "middleware" is the [requestHandler].
 */
let addStaticMiddleware: (list(string), string, t('sessionData)) => t('sessionData);

/**
 Returns [SessionConfig.t('sessionData)] from config.
 [None] if none is configured.
 */
let sessionConfig: t('sessionData) => option(SessionConfig.t('sessionData));

/**
 Returns list of middlewares from the config.
 */
let middlewares: t('sessionData) => list(Middleware.t('sessionData));

/**
 Returns [onListen] function of [t].
 */
let onListen: t('sessionData) => (unit => unit);

/**
 Returns [routeRequest] function of [t].
 */
let routeRequest: t('sessionData) => ((Route.t, Req.t('sessionData), Res.t) => Lwt.t(unit));

/**
 Returns [option(ErrorHandler.t)] of [t].
 */
let errorHandler: t('sessionData) => option(ErrorHandler.t);

/**
 Returns [option(HttpAf.Config.t)] of [t].
 */
let httpAfConfig: t('sessionData) => option(Httpaf.Config.t);