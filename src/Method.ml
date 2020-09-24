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

let of_string str =
  match String.uppercase_ascii str with
  | "GET" -> GET
  | "POST" -> POST
  | "PUT" -> PUT
  | "PATCH" -> PATCH
  | "DELETE" -> DELETE
  | "CONNECT" -> CONNECT
  | "OPTIONS" -> OPTIONS
  | "TRACE" -> TRACE
  | _ -> Other str

let to_string meth =
  match meth with
  | GET -> "GET"
  | POST -> "POST"
  | PUT -> "PUT"
  | PATCH -> "PATCH"
  | DELETE -> "DELETE"
  | CONNECT -> "CONNECT"
  | OPTIONS -> "OPTIONS"
  | TRACE -> "TRACE"
  | Other s -> s

let of_httpaf_method httpaf_meth =
  let str = Httpaf.Method.to_string httpaf_meth in
  of_string str
