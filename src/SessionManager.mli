val start_session :
  'sessionData Req.t ->
  Res.t ->
  'sessionData ->
  'sessionData Req.t * Res.t * string
(**
 	Create a new session with ['sessionData] and add cookie headers to [Res.t].  Returns newly created session id [string].
 *)

val remove_session : 'sessionData Req.t -> Res.t -> Res.t
(**
 Sets headers on [Res.t] to expire the session.
 *)

val resume_session :
  'sessionData ServerConfig.t -> 'sessionData Req.t -> 'sessionData Req.t Lwt.t
(**
  {b Intended for internal use.}

  Applies [get_session] function from [session_config] to request which uses the session id from the request cookies.
  Returns promise of a new request with session data available if it was found.
 *)

val generate_session_id : unit -> string
(**
 {b Intended for internal use.}
 *)

val sign : string -> string -> string
(**
  {b Intended for internal use.}
 *)

val unsign : string -> string -> string option
(**
  {b Intended for internal use.}
 *)
