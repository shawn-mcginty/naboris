/**
 * Represents an HTTP Method
 */
type t =
  | GET
  | POST
  | PUT
  | PATCH
  | DELETE
  | CONNECT
  | OPTIONS
  | TRACE
  | Other(string);

let ofString: string => t;

let toString: t => string;

let ofHttpAfMethod: Httpaf.Method.t => t;