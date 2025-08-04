type t

(** Get path ([string list]) of [t]. *)
val path : t -> string list

(** Get http method ([Method.t]) of [t]. *)
val meth : t -> Method.t

(** Get query [string] of [t]. *)
val rawQuery : t -> string

(** Get query map [string list Query.QueryMap.t] of [t]. *)
val query : t -> string list Query.QueryMap.t

(** {b Intended for internal use.}

    Create route record [t]. *)
val create : string list -> Method.t -> string -> string list Query.QueryMap.t -> t 