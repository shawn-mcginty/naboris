type requestHandler = (Req.t, Res.t) => unit;

type route = {
  path: string,
  method: Method.t,
  requestHandler,
};

type matcherParam = {
  name: string,
  nodeIndex: int,
};

type handler = {
  pathMatcher: Re.Pcre.regexp,
  path: string,
  pathParams: list(matcherParam),
  methods: list((Method.t, requestHandler)),
};

exception InvalidUrl(string);
exception DuplicateRoute(string);

let isParamNode = node => node.[0] == ':';

let getNodeRegexStr = node =>
  if (isParamNode(node)) {
    "\\/([^\\/]+)";
  } else {
    "\\/" ++ node;
  };

let getLastNodeRegexStr = node =>
  if (isParamNode(node)) {
    "\\/([^\\/\\?]+)";
  } else {
    "\\/" ++ node;
  };

let addArgIfNeeded = (node, args) =>
  if (isParamNode(node)) {
    let name = String.sub(node, 1, String.length(node) - 1);
    let nodeIndex = List.length(args);
    [{name, nodeIndex}, ...args];
  } else {
    args;
  };

let rec compilePathMatcher = (pathList, regexStr, args) => {
  switch (pathList) {
  | [] => (regexStr, args)
  | [lastNode] => (
      regexStr ++ getLastNodeRegexStr(lastNode),
      addArgIfNeeded(lastNode, args),
    )
  | [headNode, ...rest] =>
    compilePathMatcher(
      rest,
      regexStr ++ getNodeRegexStr(headNode),
      addArgIfNeeded(headNode, args),
    )
  };
};

let getPathRegex = path => {
  /* throw away first item, it's just an empty string */
  let treeBranch =
    switch (String.split_on_char('/', path)) {
    | [] => raise(InvalidUrl(path))
    | [_, ...rest] => rest
    };

  List.iter(
    node =>
      if (String.length(node) == 0) {
        raise(InvalidUrl(path));
      },
    treeBranch,
  );

  compilePathMatcher(treeBranch, "", []);
};

let getMethodHandler = route => (route.method, route.requestHandler);

let addNewPath = (route, handlers) => {
  let handlerPair = getMethodHandler(route);
  let (pathRegexStr, pathParams) = getPathRegex(route.path);
  let newHandler = {
    methods: [handlerPair],
    pathMatcher: Re.Pcre.regexp(pathRegexStr),
    pathParams,
    path: route.path,
  };
  [newHandler, ...handlers];
};

let addNewMethod = (route, methods: list((Method.t, requestHandler))) => {
  switch (List.find_opt(((method, _)) => method == route.method, methods)) {
  | Some(_) =>
    raise(
      DuplicateRoute(
        "Duplicate route handler defined in server options for path "
        ++ route.path,
      ),
    )
  | None => [getMethodHandler(route), ...methods]
  };
};

let addMethodToHandler = (route: route, handler: handler): handler => {
  {...handler, methods: addNewMethod(route, handler.methods)};
};

let addMethodHandler = (route: route, handlers: list(handler)) =>
  List.map(
    (handler: handler) =>
      handler.path == route.path
        ? addMethodToHandler(route, handler) : handler,
    handlers,
  );

let addRoute = (route: route, handlers: list(handler)) => {
  switch (List.find_opt(h => h.path == route.path, handlers)) {
  | None => addNewPath(route, handlers)
  | Some(_handler) => addMethodHandler(route, handlers)
  };
};

let rec builder = (routes, handlers: list(handler)) => {
  switch (routes) {
  | [] => handlers
  | [h, ...rest] => addRoute(h, handlers) |> builder(rest)
  };
};

let compileRoutes = (routes: list(route)) => builder(routes, []);

let matchPath = (target, handler) =>
  Re.Pcre.pmatch(~rex=handler.pathMatcher, target);

let getParams = (handler: handler, target: string) =>
  switch (Re.Pcre.extract(~rex=handler.pathMatcher, target) |> Array.to_list) {
  | [_h, ...params] =>
    /* skip the first one, it is not a capture group */
    List.map(
      p => (p.name, List.nth_opt(params, p.nodeIndex)),
      handler.pathParams,
    )
    |> List.filter(((_, x)) =>
         switch (x) {
         | Some(_) => true
         | _ => false
         }
       )
    |> List.map(((x, y)) =>
         switch (y) {
         | Some(z) => (x, Uri.pct_decode(z))
         | None => (x, "")
         }
       )
    |> List.filter(((_, x)) =>
         switch (x) {
         | "" => false
         | _ => true
         }
       )
  | _ => []
  };

let matchMethod = (method, target, handler) =>
  switch (List.find_opt(((m, _)) => m == method, handler.methods)) {
  | Some((_meth, h)) => Some((h, getParams(handler, target)))
  | None => None
  };

let getQuery = targetUrl => Uri.query(Uri.of_string(targetUrl));

let match =
    (routeHandlers: list(handler), target: string, method)
    : option(
        (
          requestHandler,
          list((string, string)),
          list((string, list(string))),
        ),
      ) => {
  let isMatchingPath = matchPath(target);
  let getMatchingMehtod = matchMethod(method, target);
  let meth =
    routeHandlers
    |> List.find_opt(h => isMatchingPath(h))
    |> OptionUtils.flatMap(h => getMatchingMehtod(h));

  switch (meth) {
  | None => None
  | Some((handler, params)) => Some((handler, params, getQuery(target)))
  };
};