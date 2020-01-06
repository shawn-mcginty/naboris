exception InvalidUrl(string);
exception DuplicateRoute(string);

/**
 * Generate a route record from a uri target and http method.
 */
let generateRoute: (string, Method.t) => Route.t;

/**
 * Extracts useful parts from a uri string.
 */
let processPath: string => (list(string), string, Query.QueryMap.t(list(string)));