type 'sessionData t

type httpaf_config = {
  read_buffer_size : int;
  request_body_buffer_size : int;
  response_buffer_size : int;
  response_body_buffer_size : int;
}

val make : unit -> 'sessionData t
(**
  Returns default config. Used as the starting place to build the config.
 *)

val set_on_listen : (unit -> unit) -> 'sessionData t -> 'sessionData t
(**
  Create new config from ['sessionData t] with the [on_listen] function [unit -> unit].

   [on_listen] function is called once the server is created successfully.
 *)

val set_session_config :
  ?max_age:int ->
  ?sid_key:string ->
  ?secret:string ->
  (string option -> 'sessionData Session.t option Lwt.t) ->
  'sessionData t ->
  'sessionData t
(**
  Creates new config from ['sessionData t] with [map_session] function [string option -> 'sessionData Session.t option Lwt.t].

   [map_session] function is called at the very beginning of each request/response lifecycle.
   Used to set session data into the ['sessionData Req.t] for use later in the request/response lifecycle.

   [~max_age] Optional param to set max age for session cookies in seconds (defaults to 30 days)
   [~sid_key] Optional param to set key for session cookies (defaults to ["nab.sid"])
   [~secret] Optional param but recommended to set this to a secure string.
 *)

val set_request_handler :
  (Route.t -> 'sessionData Req.t -> Res.t -> Res.t Lwt.t) ->
  'sessionData t ->
  'sessionData t
(**
  Creates new config from ['sessionDatat t] with requestHandler [Route.t -> 'sessionData Req.t -> Res.t -> Res.t Lwt.t].

   [request_handler] is the main handler function for responding to incoming http requests.
 *)

val set_error_handler : ErrorHandler.t -> 'sessionData t -> 'sessionData t
(**
  Creates new config from ['sessionData t] with errorHandler [ErrorHandler.t].

   This configuration is optional and by default [Res.reportError] will respond
   with [500] and the text of the [exn] provided.
 *)

val set_httpaf_config : httpaf_config -> 'sessionData t -> 'sessionData t
(**
  Creates new config from ['sessionData t] with httpaf_config [httpaf_config].
 *)

val add_middleware :
  'sessionData Middleware.t -> 'sessionData t -> 'sessionData t
(**
 Creates nwe config from ['sessionData t] with the added middleware ['sessionData Middleware.t].

 Middlewares are executed in the order they are added. The final "middleware" is the [request_handler].
 *)

val add_static_middleware :
  string list -> string -> 'sessionData t -> 'sessionData t
(**
 Creates a virtual path prefix [string list] and maps it to a local directory [string].

 Middlewares are executed in the order they are added.  The final "middleware" is the [request_handler].
 *)

val set_static_cache_control : string option -> 'sessionData t -> 'sessionData t
(**
  Set [Cache-control] header value which is returned with every request for a static file.

   If [None] then [Cache-control] header is omitted.
 *)

val session_config : 'sessionData t -> 'sessionData SessionConfig.t option
(**
 Returns ['sessionData SessionConfig.t] from config.
 [None] if none is configured.
 *)

val set_static_last_modified : bool -> 'sessionData t -> 'sessionData t
(**
 Set [bool] flag which [true] signals the server to send [Last-Modified] headers
 with static file responses.
 *)

val static_last_modified : 'sessionData t -> bool
(**
 Returns [bool] from config, which [true] signals the server to send [Last-Modified] headers
 with static file responses.
 *)

val set_etag : Etag.strength option -> 'sessionData t -> 'sessionData t
(**
 Set [[`Storng | `Weak] option] which signals the server to set etags as strong or weak.
 [None] will set no etag headers.
 *)

val etag : 'sessionData t -> Etag.strength option
(**
  Returns currently configured etag header strength.
 *)

val middlewares : 'sessionData t -> 'sessionData Middleware.t list
(**
  Returns list of middlewares from the config.
 *)

val on_listen : 'sessionData t -> unit -> unit
(**
  Returns [on_listen] function of [t].
 *)

val route_request :
  'sessionData t -> Route.t -> 'sessionData Req.t -> Res.t -> Res.t Lwt.t
(**
  Returns [route_request] function of [t].
 *)

val error_handler : 'sessionData t -> ErrorHandler.t option
(**
  Returns [ErrorHandler.t option] of [t].
 *)

val httpaf_config : 'sessionData t -> Httpaf.Config.t option
(**
  Returns [Httpaf.Confit.t option] of [t].
 *)

val static_cache_control : 'sessionData t -> string option
(**
  Returns [static_cache_control] value of [t].
 *)

val match_paths : string list -> string list -> string list option
(**
  {b Made public for unit tests only.}
 *)
