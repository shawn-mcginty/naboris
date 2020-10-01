type 'sessionData t

val make : string -> 'sessionData -> 'sessionData t
(**
  Creates new ['sessionData t] with id of [string].
 *)

val data : 'sessionData t -> 'sessionData
(**
  Return session data of given ['sessionData t].
 *)

val id : 'sessioData t -> string
(**
  Return session id of given ['sessionData t].
 *)
