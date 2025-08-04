exception InvalidUrl of string
exception DuplicateRoute of string

(** Generate a route record from a uri target and http method. *)
val generateRoute : string -> Method.t -> Route.t

(** Extracts useful parts from a uri string. *)
val processPath : string -> (string list * string * string list Query.QueryMap.t) 