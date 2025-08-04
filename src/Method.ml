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

let ofString str =
  match str with
  | "GET" -> GET
  | "POST" -> POST
  | "PUT" -> PUT
  | "PATCH" -> PATCH
  | "DELETE" -> DELETE
  | "CONNECT" -> CONNECT
  | "OPTIONS" -> OPTIONS
  | "TRACE" -> TRACE
  | s -> Other s

let toString meth =
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

let ofHttpAfMethod meth =
  let methString = Httpaf.Method.to_string meth in
  ofString methString 