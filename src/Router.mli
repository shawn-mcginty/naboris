exception InvalidUrl of string

exception DuplicateRoute of string

val generate_route : string -> Method.t -> Route.t
(**
  Generate a route record from a uri target and http method.
 *)

val process_path : string -> string list * string * string list Query.QueryMap.t
(**
	Extrats useful parts from a uri string.
	[(path * raw query * query)]
 *)
