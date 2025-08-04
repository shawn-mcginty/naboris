type 'sessionData t

(** Creates new ['sessionData t] with id of [string]. *)
val create : string -> 'sessionData -> 'sessionData t

(** Return session data of given ['sessionData t]. *)
val data : 'sessionData t -> 'sessionData

(** Return session id of given ['sessionData t]. *)
val id : 'sessionData t -> string 