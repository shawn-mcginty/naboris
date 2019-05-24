type t = {
  path: list(string),
  method: Method.t,
  rawQuery: string,
  query: Query.QueryMap.t(list(string)),
};