type t = {
  path: list(string),
  meth: Method.t,
  rawQuery: string,
  query: Query.QueryMap.t(list(string)),
};