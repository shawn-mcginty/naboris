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
 Creates new config from [t('sessionData)] with mapSession function [option(string) => Lwt.t(option(Session.t('sessionData)))].

 [mapSession] function is called at the very beginning of each request/response lifecycle.
 Used to set session data into the [Req.t('sessionData)] for use later in the request/response lifecycle.

 [~maxAge] Optional param to set max age for session cookies in seconds (defaults to 30 days)
 [~sidKey] Optional param to set key for session cookies (defaults to ["nab.sid"])
 [~secret] Optional param but recommended to set this to a secure string.
 */
let setSessionConfig:
  (
    ~maxAge: int=?,
    ~sidKey: string=?,
    ~secret: string=?,
    option(string) => Lwt.t(option(Session.t('sessionData))),
    t('sessionData)
  ) =>
  t('sessionData);

/**
 Creates new config from [t('sessionData)] with requestHandler [(Route.t, Req.t('sessionData), Res.t) => Lwt.t(Res.t)].

 [requestHandler] is the main handler function for responding to incoming http requests.
 */
let setRequestHandler:
  (
    (Route.t, Req.t('sessionData), Res.t) => Lwt.t(Res.t),
    t('sessionData)
  ) =>
  t('sessionData);

/**
 Creates new config from [t('sessionData)] with errorHandler [ErrorHandler.t].

 This configuration is optional and by default [Res.reportError] will respond
 with [500] and the text of the [exn] provided.
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
let addMiddleware:
  (Middleware.t('sessionData), t('sessionData)) => t('sessionData);

/**
 Creates a virtual path prefix [list(string)] and maps it to a local directory [string].

 Middlewares are executed in the order they are added.  The final "middleware" is the [requestHandler].
 */
let addStaticMiddleware:
  (list(string), string, t('sessionData)) => t('sessionData);

/**
 Set [Cache-control] header value which is returned with every request for a static file.

 If [None] then [Cache-control] header is omitted.
 */
let setStaticCacheControl: (option(string), t('sessionData)) => t('sessionData);

/**
 Returns [SessionConfig.t('sessionData)] from config.
 [None] if none is configured.
 */
let sessionConfig: t('sessionData) => option(SessionConfig.t('sessionData));

/**
 Set [bool] flag which [true] signals the server to send [Last-Modified] headers
 with static file responses.
 */
let setStaticLastModified: (bool, t('sessionData)) => t('sessionData);

/**
 Returns [bool] from config, which [true] signals the server to send [Last-Modified] headers
 with static file responses.
 */
let staticLastModified: t('sessionData) => bool;

/**
 Set [option([`Storng | `Weak])] which signals the server to set etags as strong or weak.
 [None] will set no etag headers.
 */
let setEtag: (option(Etag.strength), t('sessionData)) => t('sessionData);

/**
 Returns currently configured etag header strength.
 */
let etag: t('sessionData) => option(Etag.strength);

/**
 Returns list of middlewares from the config.
 */
let middlewares: t('sessionData) => list(Middleware.t('sessionData));

/**
 Returns [onListen] function of [t].
 */
let onListen: (t('sessionData), unit) => unit;

/**
 Returns [routeRequest] function of [t].
 */
let routeRequest:
  (t('sessionData), Route.t, Req.t('sessionData), Res.t) => Lwt.t(Res.t);

/**
 Returns [option(ErrorHandler.t)] of [t].
 */
let errorHandler: t('sessionData) => option(ErrorHandler.t);

/**
 Returns [option(HttpAf.Config.t)] of [t].
 */
let httpAfConfig: t('sessionData) => option(Httpaf.Config.t);

/**
 Returns [staticCacheControl] value of [t].
 */
let staticCacheControl: t('sessionData) => option(string);