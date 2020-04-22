---
title: Routing
---

## Routing

Decide _how_ to **respond** to a clients **request** based on the shape of said request.

- [Route Argument](#route-arg)
- [Examples](#examples)

#### <a name="route-arg" href="#route-arg">#</a> Route Argument

Routing is usually done in the `middleware` and `requestHandler` functions. Both functions take, as their first argument, a `Route.t` record. This is a helper composed of useful information from the client's http request.

The `Route` module gives functions for pulling data out of the `Route.t` record.

```ocaml
(*
 Get path ([string list]) of [t].
 *)
val path: t -> string list

(*
 Get http method ([Method.t]) of [t].
 *)
val meth: t -> Method.t

(*
 Get query [sring] of [t].
 *)
val rawQuery: t -> string

(*
 Get query map [string list Query.QueryMap.t] ot [t].
 *)
val query: t -> string list Query.QueryMap.t
```
```reason
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
```

> It is worth noting that `path` is a `URI` split by `/` characters gathered in a `list`. For example: `/my/favorite/api/endpoint` would be a list of `"my", "favorite", "api", "endpoint"`. This structure allows for easily matching on **URI parameters**.

#### <a name="examples" href="#examples">#</a> Examples

Routing is most often done via **pattern matching**.  This makes it very simple to route request to functions based on a combination of **http method** and **URI**.

```reason
Naboris.ServerConfig.create()
  |> Naboris.ServerConfig.setRequestHandler((route, req, res) => {
    switch(Naboris.Route.meth(route), Naboris.Route.path(route)) {
      | (GET, ["users"]) => // matches /users
        UserController.getAllUsers(req, res);
      | (POST, ["users"]) => // matches /users
        UserController.createUser(req, res);
      | (GET, ["users", userId]) => // matches /users/:userId with a URI parameter
        UserController.getUser(userId, req, res);
      | (PUT, ["users", userId]) => // matches /users/:userId with a URI parameter
        UserController.updateUser(userId, req, res);
      | (GET, ["blog", "articles"]) => // matches /blog/articles
        ArticleController.getAllArticles(req, res);
      | (_, ["shop", ..._rest]) => // match all request that begin with /shop
        ShopRouter.routeShopRequest(route, req, res);
      | _ => // catch any unmatched routes
        res
          |> Naboris.Res.status(404)
          |> Naboris.Res.text(req, 'Not Found');
    }
  });
```
```ocaml
Naboris.ServerConfig.create()
  |> Naboris.ServerConfig.setRequestHandler (fun route req res ->
    match(Naboris.Route.meth route, Naboris.Route.path route) with
      | (GET, ["users"]) -> (* matches /users *)
        UserController.get_all_users req res
      | (POST, ["users"]) -> (* matches /users *)
        UserController.create_user req res
      | (GET, ["users"; user_id]) -> (* matches /users/:user_id with a URI parameter *)
        UserController.get_user userId req res
      | (PUT, ["users"; user_id]) -> (* matches /users/:user_id with a URI parameter *)
        UserController.update_user userId req res
      | (PUT, ["blog"; "articles"]) -> (* matches /blog/articles *)
        ArticleController.get_all_articles route req res
      | (_, "shop" :: _rest) -> (* matches all requests that begin with /shop *)
        ShopRouter.route_shop_request req res
      | _ -> (* catch any unmatched routes *)
        res
          |> Naboris.Res.status 404
          |> Naboris.Res.text req 'Not Found')
```