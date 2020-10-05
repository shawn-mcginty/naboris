---
title: Middlewares
---

> Requests are handled by executing a stack of middlewares!

## Middlewares
A set of functions that either respond to an http request or pass it on to the next
middleware on the stack.

For this guide we will be writing two example middlewares. One to log every request and how long it takes and another which will guard a section of the website exclusive to admin users.

- [What are Middlewares?](#what-are-middlewares)
- [Authorization Example](#authorization-example)
- [Logger Example](#logger-example)
- [Combining Middlewares](#combining-middlewares)

#### <a name="what-are-middlewares" href="#what-are-middlewares">#</a> What are Middlewares?
Middlewares have a wide variety of uses.  They are executed __in the order in which they are registered__ so be sure to keep that in mind. Check out the [`Middleware module`](/odocs/naboris/Naboris/Middleware/index.html) for the spec:

```reason
// Middleware module
type t('sessionData) = (RequestHandler.t('sessionData), Route.t, Req.t('sessionData), Res.t) => Lwt.t(Res.t)
```
```ocaml
(* Middleware module *)
type 'sessionData t = 'sessionData RequestHandler.t -> Route.t -> 'sessionData Req.t -> Res.t -> Res.t Lwt.t
```

Middlewares can either handle the http request/response lifecycle themselves or call the passed in request handler (which is the next middleware in the stack) passing the `route`, `req`, and `res`.  Once the list of middlewares has been exhausted it will then be passed on to the main request handler.

#### <a name="authorization-example" href="#authorization-example">#</a> Authorization Example
We can easily create a middleware function to protect certain endpoints of our application. All middlware functions will be executed before the `request_handler`, making it easy to stop the request/response lifecycle if needed.

```reason
// ...
let serverConf: Naboris.ServerConfig.t(userData) = Naboris.ServerConfig.make()
  |> Naboris.ServerConfig.add_middleware((next, route, req, res) => switch (Naboris.Route.path(route)) {
    | ["admin", ..._] => switch (Naboris.Req.get_session_data(req)) {
      | Some({ is_admin: true, ..._}) => next(route, req, res)
      | _ =>
        res
          |> Naboris.Res.status(401)
          |> Naboris.Res.text(req, "Unauthorized");
      }
    | _ => next(route, req, res)
  });
// ...
```
```ocaml
(* ... *)
let server_conf: user_data Naboris.ServerConfig.t = Naboris.ServerConfig.make ()
  |> Naboris.ServerConfig.add_middleware (fun next route req res ->
    match (Naboris.Route.path route) with
      | "admin" :: _ ->
        (match (Naboris.Req.get_session_data req) with
          | Some({ is_admin = true; _}) -> next route req res
          | _ ->
            res
              |> Naboris.Res.status 401
              |> Naboris.Res.text req "Unauthorized")
      | _ -> next route req res)
(* ... *)
```

The above middleware example will check the session data for an `is_admin` flag on any route starting with `/admin/`, if the flag is present `next` is called and the request is handled as normal. If the flag is _not_ present the middleware completes the request/response lifecycle by sending a `401 - Unauthorized` response.


#### <a name="logger-example" href="#logger-example">#</a> Logger Example
Middlewares can also execute code _after_ the `next` function is called. This will be done in the next example which will log all incoming requests and how long it took for them to finish.

```reason
// ...
let serverConf: Naboris.ServerConfig.t(userData) = Naboris.ServerConfig.make()
  |> Naboris.ServerConfig.add_middleware((next, route, req, res) => {
    let startTime = Unix.gettimeofday();
    let path = String.concat("", Naboris.Route.path(route)) ++ Naboris.Route.raw_query(route);
    print_endline("Start Serving - " ++ path);
    Lwt.bind(() => next(route, req, res), (servedResponse) => {
      // this code is executed after next() resolves
      let endTime = Unix.gettimeofday();
      let ms = (endTime -. startTime) *. 1000);
      print_endline(path ++ " - " ++ string_of_int(Res.status(servedResponse)) ++ " - in " ++ string_of_float(ms) ++ "ms");
      Lwt.return(servedResponse);
    });
  });
// ...
```
```ocaml
(* ... *)
let server_conf: user_data Naboris.ServerConfig.t = Naboris.ServerConfig.make ()
  |> Naboris.ServerConfig.add_middleware (fun next route req res ->
    let start_time = Unix.gettimeofday () in
    let path = (String.concat "" (Naboris.Route.path route)) ^ (Naboris.Route.raw_query route) in
    let _ = print_endline ("Start Serving - " ^ path) in
    Lwt.bind(fun () -> next(route, req, res), fun servedResponse ->
      (* this code is executed after next() resolves *)
      let end_time = Unix.gettimeofday () in
      let ms = (end_time -. start_time) *. 1000 in
      let _ = print_endline (path ^ " - " ^ (string_of_int (Res.status servedResponse)) ^ " - in " ^ string_of_float(ms) ^ "ms") in
      Lwt.return servedResponse))
(* ... *)
```

#### <a name="combining-middlewares" href="#combining-middlewares">#</a> Combining Middlewares
As stated above middlewares are executed in the order in which they are registered. Given the two examples above let's see how they can be used in combination.

```reason
// ...
let serverConf: Naboris.ServerConfig.t(userData) = Naboris.ServerConfig.make()
  |> Naboris.ServerConfig.add_middleware(authorizationMiddleware)
  |> Naboris.ServerConfig.add_middleware(loggerMiddleware);
// ...
```
```ocaml
(* ... *)
let server_conf: user_data Naboris.ServerConfig.t = Naboris.ServerConfig.make ()
  |> Naboris.ServerConfig.add_middleware authorization_middleware
  |> Naboris.ServerConfig.add_middleware logger_middleware in
(* ... *)
```

This will work fine but there is a problem. If a non-admin user tries to reach a `/admin/` endpoint the request won't be logged. This is because the `authorizationMiddleware` will finish the lifecycle of the request without ever calling the `next` midddlware.

Easy to solve:

```reason
// ...
let serverConf: Naboris.ServerConfig.t(userData) = Naboris.ServerConfig.make()
  |> Naboris.ServerConfig.add_middleware(loggerMiddleware)
  |> Naboris.ServerConfig.add_middleware(authorizationMiddleware);
// ...
```
```ocaml
(* ... *)
let server_conf: user_data Naboris.ServerConfig.t = Naboris.ServerConfig.make ()
  |> Naboris.ServerConfig.add_middleware logger_middleware
  |> Naboris.ServerConfig.add_middleware authorization_middleware in
(* ... *)
```

Now all requests will be logged. Even the `401 - Unauthorized` requests.