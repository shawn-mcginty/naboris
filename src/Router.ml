exception InvalidUrl of string
exception DuplicateRoute of string

open Query

let getRawQuery uri =
  match Uri.verbatim_query uri with
  | None -> ""
  | Some rawQuery -> rawQuery

let addQuery queries (key, value) = QueryMap.add key value queries

let getQuery uri =
  match Uri.verbatim_query uri with
  | Some encodedQueryStr ->
    List.fold_left
      (fun queries (key, value) -> addQuery queries (key, value))
      QueryMap.empty
      (Uri.query_of_encoded encodedQueryStr)
  | None -> QueryMap.empty

let processPath target =
  let uri = Uri.of_string target in
  let path = String.split_on_char '/' (Uri.path uri) |> List.tl in
  (List.map Uri.pct_decode path, getRawQuery uri, getQuery uri)

let generateRoute target meth =
  let (path, rawQuery, query) = processPath target in
  Route.create path meth rawQuery query 