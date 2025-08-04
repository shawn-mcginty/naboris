type 'sessionData t = {
  getSession : string option -> 'sessionData Session.t option Lwt.t;
  sidKey : string;
  maxAge : int;
  secret : string;
}

(** Returns key to be used for session cookies. *)
val sidKey : 'sessionData t option -> string

(** Returns max age to be used for session cookies. *)
val maxAge : 'sessionData t option -> int

(** Returns secret used to sign session id cookies. *)
val secret : 'sessionData t option -> string 