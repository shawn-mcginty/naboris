type t

val path : t -> string list
(**
  Get path ([strig list]) of route [t].
 *)

val meth : t -> Method.t
(**
  Get http method ([Method.t]) of route [t].
 *)

val raw_query : t -> string
(**
  Get query [string] of route [t].
 *)

val query : t -> string list Query.QueryMap.t
(**
  Get query map ([string list Query.QueryMap.t]) of route [t].
 *)

val create :
  string list -> Method.t -> string -> string list Query.QueryMap.t -> t
(**
  {b Intended for internal use.}

  Create route record [t].
 *)
