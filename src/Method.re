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

let ofString = str => {
  switch (str) {
  | "GET" => GET
  | "POST" => POST
  | "PUT" => PUT
  | "PATCH" => PATCH
  | "DELETE" => DELETE
  | "CONNECT" => CONNECT
  | "OPTIONS" => OPTIONS
  | "TRACE" => TRACE
  | s => Other(s)
  };
};

let toString = meth => {
  switch (meth) {
  | GET => "GET"
  | POST => "POST"
  | PUT => "PUT"
  | PATCH => "PATCH"
  | DELETE => "DELETE"
  | CONNECT => "CONNECT"
  | OPTIONS => "OPTIONS"
  | TRACE => "TRACE"
  | Other(s) => s
  };
};

let ofHttpAfMethod = meth => {
  let methString = Httpaf.Method.to_string(meth);
  ofString(methString);
};