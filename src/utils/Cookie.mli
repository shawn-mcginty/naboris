val get_session_id : string -> string -> string option
(**
  Given the session id key and cookie header string values extracts sessonId
 *)

val session_id_of_req : 'sessionData Req.t -> string option
(**
  Extract session_id from http cookie headers in [Req.t]
 *)
