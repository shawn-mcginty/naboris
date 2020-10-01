exception InvalidUrl of string

exception DuplicateRoute of string

open Query

let get_raw_query uri =
  match Uri.verbatim_query uri with None -> "" | Some raw_query -> raw_query

let add_query queries (key, value) = QueryMap.add key value queries

let get_query uri =
  match Uri.verbatim_query uri with
  | Some encoded_query_str ->
      List.fold_left add_query QueryMap.empty
        (Uri.query_of_encoded encoded_query_str)
  | None -> QueryMap.empty

let process_path target =
  let uri = Uri.of_string target in
  let full_path = Uri.path uri in
  let path = String.split_on_char '/' full_path |> List.tl in
  (List.map Uri.pct_decode path, get_raw_query uri, get_query uri)

let generate_route target meth =
  let path, raw_query, query = process_path target in
  Route.create path meth raw_query query
