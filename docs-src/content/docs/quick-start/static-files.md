---
title: Static Files
---

## Static Files
**naboris** provides some helpers to make serving static files easy.

- [Middleware](#middleware)
- [Routing](#routing)

#### <a name="middleware" href="#middleware">#</a> Middleware

`Naboris.ServerConfig` has a sweet helper function to create a middleware
which will map incoming requests to a local directory.

```reason
/**
 Creates a virtual path prefix [list(string)] and maps it to a local directory [string].

 Middlewares are executed in the order they are added.  The final "middleware" is the [requestHandler].
 */
let addStaticMiddleware: (list(string), string, t('sessionData)) => t('sessionData);
```
```ocaml
(**
 Creates a virtual path prefix [string list] and maps it to a local directory [string].

 Middlewares are executed in the order they are added.  The final "middleware" is the [requestHandler].
*)
val addStaticMiddleware: string list -> string -> 'sessionData t -> 'sessionData t
```

* `list(string)` - Will match against the `Route.path` of each incoming request.
* `string` - Path to a local directory which will have the rest of the path applied to.
* `t` - Current `Naboris.ServerConfig`.

The rest of the incoming request will be applied to the local path
e.g. given inputs `["static"], "/path/to/public"` a request for `/static/images/logo.png` would map to `/path/to/public/images/logo.png`.

```reason
let serverConfig = Naboris.ServerConfig.create()
  |> Naboris.ServerConfig.addStaticMiddleware(["static"], Sys.getcwd("cur__root") ++ "/public/");
```
```ocaml
let server_config = Naboris.ServerConfig.create ()
  |> Naboris.ServerConfig.addStaticMiddleware
    ["static"]
    (Sys.getcwd () ^ "/public/") in
```

#### <a name="routing" href="#routing">#</a> Routing

For more fine grained control over serving static files there is also
a helper function `Res.static`.  The inputs are the same as the above
middleware helper function.

```reason
let publicDir = Sys.getcwd() ++ "/public/";
let serverConfig = Naboris.ServerConfig.create()
  |> Naboris.ServerConfig.setRequestHandler((route, req, res) => {
    switch (Naboris.Route.meth(route), Naboris.Route.path(route)) {
      | _ =>
          Naboris.Res.status(404, res)
          |> Naboris.Res.static(publicDir, ["not_found.html"], req);
    }
  });
```
```ocaml
let public_dir = Sys.getcwd () ^ "/public/" in
let server_config = Naboris.ServerConfig.create ()
  |> Naboris.ServerConfig.setRequestHandler(fun route req res ->
    match (Naboris.Route.meth route, Naboris.Route.path route) with
      | _ ->
        Naboris.Res.status 404 res
          |> Naboris.Res.static
            public_dir
            ["not_found.html"]
            req) in
```
