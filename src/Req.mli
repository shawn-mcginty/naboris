type 'sessionData t

val reqd : 'sessionData t -> Httpaf.Reqd.t
(**
  Get Httpaf request descriptor.
 *)

val get_header : string -> 'sessionData t -> string option
(**
  Get header from request.
  [None] if no matching header is found.
 *)

val get_body : 'sessionData t -> string Lwt.t
(**
  Get lwt promise of the body string from an http request.
 *)

val get_session_data : 'sessionData t -> 'sessionData option
(**
  Exracts ['sessionData] from request.
  Returns [None] if no session exists.
 *)

val set_session_data :
  'sessionData Session.t option -> 'sessionData t -> 'sessionData t
(**
  Returns new `['sessionData t]` with session_data set.
 *)

val from_reqd :
  Httpaf.Reqd.t ->
  'sessionData SessionConfig.t option ->
  string option ->
  bool ->
  Etag.strength option ->
  'sessionData t
(**
  {b Intended for internal use.}
  Creates default req record.
 *)

val sid_key : 'sessionData t -> string
(**
  Get key for session id cookie
 *)

val max_age : 'sessionData t -> int
(**
 Get max age for session id cookies (in seconds)
 *)

val secret : 'sessionData t -> string
(**
 Get secret used to sign session id cookies.
 *)

val static_cache_control : 'sessionData t -> string option
(**
  Get [Cache-control] header value for static requests based on [ServerConfig.t].
 *)

val static_last_modified : 'sessionData t -> bool
(**
  Get [bool] value where true signals the server to set [Last-modified] headers for static requests.
 *)

val response_etag : 'sessionData t -> Etag.strength option
(**
  Get [[`Strong | `Weak] option] which is set by [ServerConfig.t].
 *)
