type t = {
  path : string list;
  meth : Method.t;
  rawQuery : string;
  query : string list Query.QueryMap.t;
}

let create path meth rawQuery query = {path; meth; rawQuery; query}
let path r = r.path
let meth r = r.meth
let rawQuery r = r.rawQuery
let query r = r.query 