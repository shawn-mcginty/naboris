type 'sessionData t

type httpAfConfig = {
  read_buffer_size : int;
  request_body_buffer_size : int;
  response_buffer_size : int;
  response_body_buffer_size : int;
}

(** Returns default config.  Used as the starting place to build the config. *)
val create : unit -> 'sessionData t

(** Create new config from [t('sessionData)] with the onListen function [unit -> unit].

    [onListen] function is called once the server is created successfully. *)
val setOnListen : (unit -> unit) -> 'sessionData t -> 'sessionData t

(** Creates new config from [t('sessionData)] with mapSession function [string option -> Session.t('sessionData) option Lwt.t].

    [mapSession] function is called at the very beginning of each request/response lifecycle.
    Used to set session data into the [Req.t('sessionData)] for use later in the request/response lifecycle.

    [~maxAge] Optional param to set max age for session cookies in seconds (defaults to 30 days)
    [~sidKey] Optional param to set key for session cookies (defaults to ["nab.sid"])
    [~secret] Optional param but recommended to set this to a secure string. *)
val setSessionConfig :
  ?maxAge:int ->
  ?sidKey:string ->
  ?secret:string ->
  (string option -> 'sessionData Session.t option Lwt.t) ->
  'sessionData t ->
  'sessionData t

(** Creates new config from [t('sessionData)] with requestHandler [(Route.t * Req.t('sessionData) * Res.t) -> Res.t Lwt.t].

    [requestHandler] is the main handler function for responding to incoming http requests. *)
val setRequestHandler :
  (Route.t -> 'sessionData Req.t -> Res.t -> Res.t Lwt.t) ->
  'sessionData t ->
  'sessionData t

(** Creates new config from [t('sessionData)] with errorHandler [ErrorHandler.t].

    This configuration is optional and by default [Res.reportError] will respond
    with [500] and the text of the [exn] provided. *)
val setErrorHandler : ErrorHandler.t -> 'sessionData t -> 'sessionData t

(** Creates new config from [t('sessionData)] with httpAfConfig [httpAfConfig]. *)
val setHttpAfConfig : httpAfConfig -> 'sessionData t -> 'sessionData t

(** Creates new config from [t('sessionData)] with the added middleware [Middleware.t('sessionData)].

    Middlewares are executed in the order they are added.  The final "middleware" is the [requestHandler]. *)
val addMiddleware : 'sessionData Middleware.t -> 'sessionData t -> 'sessionData t

(** Creates a virtual path prefix [string list] and maps it to a local directory [string].

    Middlewares are executed in the order they are added.  The final "middleware" is the [requestHandler]. *)
val addStaticMiddleware : string list -> string -> 'sessionData t -> 'sessionData t

(** Set [Cache-control] header value which is returned with every request for a static file.

    If [None] then [Cache-control] header is omitted. *)
val setStaticCacheControl : string option -> 'sessionData t -> 'sessionData t

(** Returns [SessionConfig.t('sessionData)] from config.
    [None] if none is configured. *)
val sessionConfig : 'sessionData t -> 'sessionData SessionConfig.t option

(** Set [bool] flag which [true] signals the server to send [Last-Modified] headers
    with static file responses. *)
val setStaticLastModified : bool -> 'sessionData t -> 'sessionData t

(** Returns [bool] from config, which [true] signals the server to send [Last-Modified] headers
    with static file responses. *)
val staticLastModified : 'sessionData t -> bool

(** Set [Etag.strength option] which signals the server to set etags as strong or weak.
    [None] will set no etag headers. *)
val setEtag : Etag.strength option -> 'sessionData t -> 'sessionData t

(** Returns currently configured etag header strength. *)
val etag : 'sessionData t -> Etag.strength option

(** Returns list of middlewares from the config. *)
val middlewares : 'sessionData t -> 'sessionData Middleware.t list

(** Returns [onListen] function of [t]. *)
val onListen : 'sessionData t -> unit -> unit

(** Returns [routeRequest] function of [t]. *)
val routeRequest : 'sessionData t -> Route.t -> 'sessionData Req.t -> Res.t -> Res.t Lwt.t

(** Returns [ErrorHandler.t option] of [t]. *)
val errorHandler : 'sessionData t -> ErrorHandler.t option

(** Returns [Httpaf.Config.t option] of [t]. *)
val httpAfConfig : 'sessionData t -> Httpaf.Config.t option

(** Returns [staticCacheControl] value of [t]. *)
val staticCacheControl : 'sessionData t -> string option 