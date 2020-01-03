exception InvalidUrl(string);
exception DuplicateRoute(string);

open Query;

let getRawQuery = uri =>
  switch (Uri.verbatim_query(uri)) {
  | None => ""
  | Some(rawQuery) => rawQuery
  };

let addQuery = (queries, (key, value)) => QueryMap.add(key, value, queries);

let getQuery = uri =>
  switch (Uri.verbatim_query(uri)) {
  | Some(encodedQueryStr) =>
    List.fold_left(
      (queries, (key, value)) => addQuery(queries, (key, value)),
      QueryMap.empty,
      Uri.query_of_encoded(encodedQueryStr),
    )
  | None => QueryMap.empty
  };

let processPath = target => {
  let uri = Uri.of_string(target);
  let path = String.split_on_char('/', Uri.path(uri)) |> List.tl;
  (List.map(Uri.pct_decode, path), getRawQuery(uri), getQuery(uri));
};

let generateRoute = (target, meth) => {
  let (path, rawQuery, query) = processPath(target);
  Route.{path, rawQuery, query, meth};
};