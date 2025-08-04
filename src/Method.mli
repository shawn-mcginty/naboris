(** Represents an HTTP Method *)
type t =
  | GET
  | POST
  | PUT
  | PATCH
  | DELETE
  | CONNECT
  | OPTIONS
  | TRACE
  | Other of string

val ofString : string -> t

val toString : t -> string

val ofHttpAfMethod : Httpaf.Method.t -> t 