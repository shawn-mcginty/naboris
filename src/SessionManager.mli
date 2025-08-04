(** Create a new session with ['sessionData] and add cookie headers to [Res.t].  Returns newly created session id [string]. *)
val startSession : 'sessionData Req.t -> Res.t -> 'sessionData -> ('sessionData Req.t * Res.t * string)

(** Sets headers on `Res.t` to expire the session. *)
val removeSession : 'sessionData Req.t -> Res.t -> Res.t

(** {b Intended for internal use.}

    Applies [mapSession] from config to request which uses the session id from the request cookies.
    Returns promise of a new request with session data available if it was found. *)
val resumeSession : 'sessionData ServerConfig.t -> 'sessionData Req.t -> 'sessionData Req.t Lwt.t

(** {b Intended for internal use.} *)
val generateSessionId : unit -> string

(** {b Intended for internal use.} *)
val sign : string -> string -> string

(** {b Intended for internal use.} *)
val unsign : string -> string -> string option 