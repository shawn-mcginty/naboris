type t = {
  path : string list;
  meth : Method.t;
  raw_query : string;
  query : string list Query.QueryMap.t;
}

let create path meth raw_query query = { path; meth; raw_query; query }

let path r = r.path

let meth r = r.meth

let raw_query r = r.raw_query

let query r = r.query
