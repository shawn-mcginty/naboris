type httpAfConfig = {
  read_buffer_size : int;
  request_body_buffer_size : int;
  response_buffer_size : int;
  response_body_buffer_size : int;
}

type 'sessionData t = {
  onListen : unit -> unit;
  routeRequest : Route.t -> 'sessionData Req.t -> Res.t -> Res.t Lwt.t;
  sessionConfig : 'sessionData SessionConfig.t option;
  errorHandler : ErrorHandler.t option;
  httpAfConfig : httpAfConfig option;
  middlewares : 'sessionData Middleware.t list;
  staticCacheControl : string option;
  staticLastModified : bool;
  etag : Etag.strength option;
}

let default = {
  onListen = (fun () -> ());
  errorHandler = None;
  routeRequest = (fun _route req res -> 
    res |> Res.status 404 |> Res.raw req "Resource not found");
  sessionConfig = None;
  httpAfConfig = None;
  middlewares = [];
  staticCacheControl = Some "public, max-age=0";
  staticLastModified = true;
  etag = Some `Weak;
}

let sessionConfig conf = conf.sessionConfig

let errorHandler conf = conf.errorHandler

let routeRequest conf = conf.routeRequest

let onListen conf = conf.onListen

let create () = default

let setOnListen onListenFn conf = { conf with onListen = onListenFn }

let setRequestHandler reqHandlerFn conf = {
  conf with routeRequest = reqHandlerFn;
}

let setErrorHandler errHandlerFn conf = {
  conf with errorHandler = Some errHandlerFn;
}

let setHttpAfConfig httpAfConfig conf = {
  conf with httpAfConfig = Some httpAfConfig;
}

let addMiddleware middleware conf = {
  conf with middlewares = List.append conf.middlewares [middleware];
}

let middlewares conf = conf.middlewares

let rec matchPaths matcher path =
  match (matcher, path) with
  | ([x], y :: rest) when x = y -> Some rest
  | (x :: restMatcher, y :: restPath) when x = y ->
    matchPaths restMatcher restPath
  | _ -> None

let addStaticMiddleware pathPrefix publicPath conf =
  conf
  |> addMiddleware (fun next route req res ->
       match (Route.meth route, Route.path route) with
       | (Method.GET, path) ->
         (match matchPaths pathPrefix path with
         | Some remainingPath ->
           Res.static publicPath remainingPath req res
         | _ -> next route req res)
       | _ -> next route req res)

let setSessionConfig ?(maxAge=2592000) ?(sidKey="nab.sid") ?(secret="please set to a secure value") getSessionFn conf =
  let sessionConfig : 'sessionData SessionConfig.t = {
    SessionConfig.getSession = getSessionFn;
    maxAge;
    sidKey;
    secret;
  } in
  { conf with sessionConfig = Some sessionConfig }

let staticCacheControl conf = conf.staticCacheControl

let setStaticCacheControl cacheControl conf = { conf with staticCacheControl = cacheControl }

let staticLastModified conf = conf.staticLastModified

let setStaticLastModified staticLastModified conf = { conf with staticLastModified }

let etag conf = conf.etag

let setEtag etag (conf : 'sessionData t) = { conf with etag }

let httpAfConfig (conf : 'sessionData t) : Httpaf.Config.t option =
  match conf.httpAfConfig with
  | None -> None
  | Some httpConf ->
    let {
      read_buffer_size;
      request_body_buffer_size;
      response_buffer_size;
      response_body_buffer_size;
    } = httpConf in
    Some {
      Httpaf.Config.read_buffer_size;
      request_body_buffer_size;
      response_buffer_size;
      response_body_buffer_size;
    } 