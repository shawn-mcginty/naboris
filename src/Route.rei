type t;

/**
 Create route record [t].
 */
let create: (list(string), Method.t, string, Query.QueryMap.t(list(string))) => t;

/**
 Get path ([list(string)]) of [t].
 */
let path: t => list(string);

/**
 Get http method ([Method.t]) of [t]. 
 */
let meth: t => Method.t;

/**
 Get query [sring] of [t].
 */
let rawQuery: t => string;

/**
 Get query map [Query.QueryMap.t(list(string))] ot [t].
 */
let query: t => Query.QueryMap.t(list(string));