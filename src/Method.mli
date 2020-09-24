(**
 Represents an HTTP Method
 *)
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

val of_string : string -> t

val to_string : t -> string

val of_httpaf_method : Httpaf.Method.t -> t
