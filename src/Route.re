type t = {
  path: list(string),
  meth: Method.t,
  rawQuery: string,
  query: Query.QueryMap.t(list(string)),
};

let create = (path, meth, rawQuery, query) => ({path, meth, rawQuery, query});
let path = r => r.path;
let meth = r => r.meth;
let rawQuery = r => r.rawQuery;
let query = r => r.query;