type 'sessionData t

(** Get HttpAf request descriptor. *)
val reqd : 'sessionData t -> Httpaf.Reqd.t

(** Get header from request.
    [None] if no matching header is found. *)
val getHeader : string -> 'sessionData t -> string option

(** Get lwt promise of the body string from an http request. *)
val getBody : 'sessionData t -> string Lwt.t

(** Extracts ['sessionData] from request.

    Returns [None] if no session exists. *)
val getSessionData : 'sessionData t -> 'sessionData option

(** Sets ['sessionData] onto a request. *)
val setSessionData : 'sessionData Session.t option -> 'sessionData t -> 'sessionData t

(** {b Intended for internal use.}
    Creates default req record. *)
val fromReqd : Httpaf.Reqd.t -> 'sessionData SessionConfig.t option -> string option -> bool -> Etag.strength option -> 'sessionData t

(** Get key for session id cookie *)
val sidKey : 'sessionData t -> string

(** Get max age for session id cookies (in seconds) *)
val maxAge : 'sessionData t -> int

(** Get secret used to sign session id cookies. *)
val secret : 'sessionData t -> string

(** Get [Cache-control] header value for static requests based on [ServerConfig.t]. *)
val staticCacheControl : 'sessionData t -> string option

(** Get [bool] value where true signals the server to set [Last-modified] headers for static requests. *)
val staticLastModified : 'sessionData t -> bool

(** Get [Etag.strength option] which is set by [ServerConfig.t]. *)
val responseEtag : 'sessionData t -> Etag.strength option 