type 'sessionData t = {
  get_session : string option -> 'sessionData Session.t option Lwt.t;
  sid_key : string;
  max_age : int;
  secret : string;
}

val sid_key : 'sessionData t option -> string
(**
  Returns key to be used for session cookies.
 *)

val max_age : 'sessionData t option -> int
(**
  Returns max age to be used for session cookies.
 *)

val secret : 'sessionData t option -> string
(**
  Returns secret used to sign session id cookies.
 *)
