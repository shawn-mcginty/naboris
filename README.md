# Naboris
Simple, fast, minimalist web framework for [OCaml](https://ocaml.org)/[ReasonML](https://reasonml.github.io) built on [httpaf](https://github.com/inhabitedtype/httpaf) and [lwt](https://github.com/ocsigen/lwt).

[![Build Status](https://travis-ci.com/shawn-mcginty/naboris.svg?branch=master)](https://travis-ci.com/shawn-mcginty/naboris)
[![opam version 0.1.0](https://img.shields.io/static/v1?label=opam&message=0.1.0&color=E7C162)](https://opam.ocaml.org/packages/naboris/)

[odocs avialable here][docs html index]

```reason
// ReasonML
let serverConfig: Naboris.ServerConfig.t(unit) = Naboris.ServerConfig.create()
  |> Naboris.ServerConfig.setRequestHandler((route, req, res) => switch(Naboris.Route.path(route)) {
    | ["hello"] =>
      res
        |> Naboris.Res.status(200)
        |> Naboris.Res.text(req, "Hello world!");
    | _ =>
      res
        |> Naboris.Res.status(404)
        |> Naboris.Res.text(req, "Resource not found.");
  });

Lwt_main.run(Naboris.listenAndWaitForever(3000, serverConfig));
/* In a browser navigate to http://localhost:3000/hello */
```

```ocaml
(* OCaml *)
let server_config: unit Naboris.ServerConfig.t = Naboris.ServerConfig.create ()
  |> Naboris.ServerConfig.setRequestHandler(fun route req res ->
    match (Naboris.Route.path route) with
      | ["hello"] ->
        res
          |> Naboris.Res.text req "Hello world!";
      | _ ->
        res
          |> Naboris.Res.status 404
          |> Naboris.Res.text req "Resource not found.";
  ) in


let _ = Lwt_main.run(Naboris.listenAndWaitForever 3000 server_config)
(* In a browser navigate to http://localhost:3000/hello *)
```

## Contents
* [Getting Started](#getting-started)
    * [Installation](#installation)
    * [Server Config](#server-config)
    * [Routing](#routing)
    * [Static Files](#static-files)
    * [Session Data](#session-data)
* [Advanced](#advanced)
	* [Middlewares](#middlewares)
* [Development](#development)

```
                                                           
 @@@@@  @@@@  @@@@@                                        
 *@*   @@@@@@   @@&                                        
  @@&  .@@@@  @@@/        @@,         (@@@                 
    ,    @@             @@@@@@@      @@@@@@@               
                       @@@@@@@@,    @@@@@@@@@              
        @@@*           @@@@@@@@@@@@@@@@@@@@@@              
       &@@@@          @@@@@@@@@@@@@.      &@@              
    @@@@@@@@           @@@@@@@@@@@@@@#(%(                  
    @@@@@  @@         .@@@@@@@@@@@@@@@@@@@@@*              
       ,@#  @*       @@@@@@@@@@@@@@@@@@@@@@@@@             
     # ,@@   @@     ,@@@@@@@@@@@@@@@@@@@@@@@@@@            
    .@@@@@.  .@@@   @@@@@@@@@@@@@@@@@@@@@@@@@@@@           
         @@.   @@@@ %@@@@@@@@@@@@@@@@@@@@@@@@@@@&          
         &@@*       .@@@.@@@@@@@@@@@*     (@@@@@@@@@@@@@@  
       @@@@@@@       @   @@@@@@@@@@   %@&   @@@@@@@@@@@*   
        @@  @@@@@      .@@@@@@@@ @  /@@@@@@     #@@@@@     
             @@@@@@    @@@@@@@@@    @@@@@@@@       @       
            @@@   %@   @@  , .@@   %@@(@&,@@%              
              ,          @@@@*       @@@@@                 
                         @@@@@        @@@@                 
                         @@@@@        @@@.                 
                         @@@@@        @@@%                 
                         @@@@@        @@@                  
                          %@           @.                  
                          (@           @                   
                          .%           ,                   
                                                           
                          @@(          @@                  
```

## Getting Started

### Installation

#### opam
```bash
opam install naboris
```

#### esy
```json
"@opam/naboris": "^0.1.0"
```

#### dune
```
(libraries naboris)
```

### Server Config
The `Naboris.ServerConfig.t('sessionData)` type will define the way your server will handle requests.

#### Creating a Server Config

There are a number of helper functions for building server config records.

##### ServerConfig.create
__create__ is used to generate a default server config object, this will be the starting point.
```reason
// ReasonML
let create: unit => ServerConfig.t('sessionData);
```
```ocaml
(* OCaml *)
val create: unit -> 'sessionData ServerConfig.t
```

#### ServerConfig.setOnListen
__setOnListen__ will set the function that will be called once the server has started and is listening for connections.  The `onListen` function has the type signature `unit => unit`.
```reason
// ReasonML
let setOnListen: (unit => unit, ServerConfig.t('sessionData)) => ServerConfig.t('sessionData)
```
```ocaml
(* OCaml *)
val setOnListen: (unit -> unit) -> 'sessionData ServerConfig.t -> 'sessionData ServerConfig.t
```

#### ServerConfig.setRequestHandler
__setRequestHandler__ will set the main request handler function on the config.  This function is the main entry point for http requests and usually where routing the request happens.  The `requestHandler` function has the type signature `(Route.t, Req.t('sessionData), Res.t) => Lwt.t(unit)`.
```reason
// ReasonML
let setRequestHandler: (
  (Route.t, Req.t('sessionData), Res.t) => Lwt.t(unit),
  ServerConfig.t('sessionData)
) => ServerConfig.t('sessionData)
```
```ocaml
(* OCaml *)
val setRequestHandler: (Route.t -> 'sessionData Req.t -> Res.t -> unit Lwt.t)
  -> 'sessionData ServerConfig.t -> 'sessionData ServerConfig.t
```

### Routing
Routin is intended to be done via pattern matching in the main `requestHandler` function.  This function takes as it's first argument a `Route.t` record, which looks like this:
```reason
// ReasonML
/* module Naboris.Route */
module type Route = {
  type t;
  let path: t => list(string),
  let meth: t => Method.t,
  let rawQuery: t => string,
  let query: t =>Query.QueryMap.t(list(string)),
};
```
```ocaml
(* OCaml *)
module Route : sig
  type t;
  val path = t -> string list
  val meth = t -> Method.t
  val rawQuery = t -> string
  val query = t -> string list Qyery.QueryMap.t
end
```

For these examples we'll be matching on `path` and `meth`.
> Note: `path` is the url path broken into an array by the `/` separators.
> e.g. `/user/1/contacts` would look like this: `["user", "1", "contacts"]`

```reason
// ReasonML
let requestHandler = (route, req, res) => switch (Naboris.Route.meth(route), Naboris.Route.path(route)) {
  | (Naboris.Method.GET, ["user", userId, "contacts"]) =>
    /* Use pattern matching to pull parameters out of the url */
    let contacts = getContactsByUserId(userId);
    let contactsJsonString = serializeToJson(contacts);
    res
      |> Naboris.Res.status(200)
      |> Naboris.Res.json(req, contactsJsonString);
  | (Naboris.Method.PUT, ["user", userId, "contacts"]) =>
    /* for the sake of this example we're not using ppx or infix */
    /* lwt promises can be made much easier to read by using these */
    Lwt.bind(
      Naboris.Req.getBody(req),
      bodyStr => {
      	let newContacts = parseJsonString(bodyStr);
        let _ = addNewContactsToUser(userId, newContacts);
        res
          |> Naboris.Res.status(201)
          |> Naboris.Res.text(req, "Created");
      },
    )
  | _ =>
      res
        |> Naboris.Res.status(404)
        |> Naboris.Res.text(req, "Resource not found.");
};
```
```ocaml
(* OCaml *)
let request_handler route req res =
  match ((Naboris.Route.meth route), (Naboris.Route.path route)) with
    | (Naboris.Method.GET, ["user"; user_id; "contacts"]) ->
      (* Use pattern matching to pull parameters out of the url *)
      let contatcs = get_contacts_by_user_id user_id in
      let contacts_json_string = serialize_to_json contacts in
      res
        |> Naboris.Res.status 200
        |> Naboris.Res.json req contacts_json_string;
    | (Naboris.Method.PUT, ["user"; user_id; "contacts"]) ->
      (* for the sake of this example we're not using ppx or infix *)
      (* lwt promises can be made much easier to read by using these *)
      Lwt.bind Naboris.Req.getBody req (fun body_str ->
        let new_contacts = parse_json_string body_str in
        let _ = add_new_contacts_to_user user_id new_contacts in
        res
          |> Naboris.Res.status 201
          |> Naboris.Res.text req "Created")
    | _ ->
      res
        |> Naboris.Res.status 404
        |> Naboris.Res.text req "Resource not found."
```

### Static Files
While it is recommended to use a reverse proxy or other such service for serving static files `Naboris` does have helper functions to make this easy.  The `Res` module has the `static` function for this exact reason. The 

```reason
// ReasonML
let static : (string, list(string), Req.t('sessionData), Res.t) => Lwt.t(unit)
```
```ocaml
(* OCaml *)
val static : string -> string list -> 'sessionData Req.t -> Res.t -> unit Lwt.t
```

* `string`: Being the root directory from which to read static files
* `string list`: Being the split path from the root directory to read the specific static file
* `'sessionData Req.t`: The current naboris request
* `Res.t`: The current naobirs response

A pattern matcher for static file routes might look like this
```reason
// ReasonML
switch (Naboris.Route.meth(route), Naboris.Route.path(route)) {
  | (Naboris.Method.GET, ["static", ...staticPath]) =>
    Naboris.Res.static(
      Sys.getenv("cur__root") ++ "/static-assets",
      staticPath,
      req,
      res,
    )
}
```
```ocaml
(* OCaml *)
match ((Naboris.Route.meth route), (Naboris.Route.path route)) with
  | (Naboris.Method.GET, "static" :: static_path) ->
    Naboris.Res.static(
      (Sys.getenv "cur__root") ++ "/static-assets",
      static_path,
      req,
      res,
    )
```

In the case above `/static/images/icon.png` would be served from `$cur__root/static-assets/images/icon.png`

### Session Data
Many `Naboris` types take the parameter `'sessionData` this represents a custom data type that will define session data that will be attached to an incoming request.

#### sessionGetter
__Naboris.ServerConfig.setSessionGetter__ will set the configuration with a function with the signature `option(string) => Lwt.t(option(Naboris.Session.t('sessionData)))`.  That's a complicated type signature that expresses that the request may or may not have a `sessionId`; and given that fact it may or may not return a session.
```reason
// ReasonML
// Your custom data type
type userData = {
  userId: int,
  username: string,
  firstName: string,
  lastName: string,
  isAdmin: bool,
};

let serverConfig: Naboris.ServerConfig(userData) = Naboris.ServerConfig.create()
  |> Naboris.ServerConfig.setSessionGetter(sessionId => switch(sessionId) {
    | Some(id) =>
      /* for the sake of this example we're not using ppx or infix */
      /* lwt promises can be made much easier to read by using these */
      Lwt.bind(getUserDataById(id),
        userData => {
          let session = Naboris.Session.create(id, userData);
          Lwt.return(Some(session));
        }
      );
    | None => Lwt.return(None);
  })
  |> Naboris.ServerConfig.setRequestHandler((route, req, res) => switch(Naboris.Route.meth(meth), Naboris.Route.path(route)) {
    | (Naboris.Method.POST, ["login"]) =>
      let (req2, res2, _sessionId) =
        /* Begin a session */
        Naboris.SessionManager.startSession(
          req,
          res,
          {
            userId: 1,
            username: "foo",
            firstName: "foo",
            lastName: "bar",
            isAdmin: false,
          },
        );
        Naboris.Res.status(200, res2) |> Naboris.Res.text(req2, "OK");
    | (Naboris.Method.GET, ["who-am-i"]) =>
      /* Get session data from the request */
      switch (Naboris.Req.getSessionData(req)) {
      | None =>
        Naboris.Res.status(404, res) |> Naboris.Res.text(req, "Not found")
      | Some(userData) =>
        Naboris.Res.status(200, res)
        |> Naboris.Res.text(req, userData.username)
      };
  });
```
```ocaml
(* OCaml *)
(* Your custom session data *)
type user_data = {
  userId: int,
  username: string,
  first_name: string,
  last_name: string,
  is_admin: bool,
}

let serverConfig: user_data Naboris.ServerConfiguserData = Naboris.ServerConfig.create ()
  |> Naboris.ServerConfig.setSessionGetter (fun session_id ->
    match (session_id) with
      | Some(id) =>
        (* for the sake of this example we're not using ppx or infix *)
        (* lwt promises can be made much easier to read by using these *)
        Lwt.bind (get_user_data_by_id id) (fun user_data ->
          let session = Naboris.Session.create id user_data in
	  Lwt.return Some(session)
        )
    | None => Lwt.return None)
  |> Naboris.ServerConfig.setRequestHandler (fun route, req, res ->
    match ((Naboris.Route.meth route), (Naboris.Route.path route)) with
      | (Naboris.Method.POST, ["login"]) ->
        let (req2, res2, _session_id) =
        (* Begin a session *)
          Naboris.SessionManager.startSession req res {
            userId: 1,
            username: "foo",
            first_name: "foo",
            last_name: "bar",
            is_admin: false,
          } in
        Naboris.Res.status 200 res2
          |> Naboris.Res.text req2, "OK"
    | (Naboris.Method.GET, ["who-am-i"]) ->
      (* Get session data from the request *)
      match (Naboris.Req.getSessionData req) with
        | None ->
          Naboris.Res.status 404 res
            |> Naboris.Res.text req "Not found"
        | Some(user_data) ->
          Naboris.Res.status 200 res
            |> Naboris.Res.text req user_data.username)
```

## Advanced

### Middlewares
Middlewares have a wide variety of uses.  They are executed __in the order in which they are registered__ so be sure to keep that in mind. Middlewares are functions with the following signature:

`Naboris.RouteHandler.t -> Naboris.Route.t -> Naboris.Req.t -> Naboris.Res.t -> unit Lwt.t`

Middlewares can either handle the http request/repsonse lifecycle themselves or call the passed in route handler passing the req/res on to the next middleware in the list.  Once the list of middlewares has been exaused it will then be passed on to the default route handler.

One simple example of a middleware would be one that protects certain routes from users without specific permissions.

Given the __Sesson Data__ example above, one such middleware might look like this:
```reason
// ReasonML
let serverConf: Naboris.ServerConfig.t(userData) = Naboris.ServerConfig.create()
  |> Naboris.ServerConfig.addMiddleware((next, route, req, res) => switch (Naboris.Route.path(route)) {
    | ["admin", ..._] => switch (Naboris.Req.getSessionData(req)) {
      | Some({ is_admin: true, ..._}) => next(route, req, res)
      | _ =>
        res
          |> Naboris.Res.status(401)
          |> Naboris.Res.text(req, "Unauthorized");
      }
    | _ => next(route, req, res)
  });
```
```ocaml
(* OCaml *)
let server_conf: user_data Naboris.ServerConfig.t = Naboris.ServerConfig.create ()
  |> Naboris.ServerConfig.addMiddleware (fun next route req res ->
    match (Naboris.Route.path route) with
      | "admin" :: _ ->
        (match (Naboris.Req.getSessionData req) with
          | Some({ is_admin = true; _}) -> next route req res
          | _ ->
            res
              |> Naboris.Res.status 401
              |> Naboris.Res.text req "Unauthorized")
      | _ -> next route req res)
```

## Development
Any help would be greatly appreciated! 👍

### To run tests

```bash
esy install
npm run test
```
[docs html index]: https://shawn-mcginty.github.io/naboris/docs/html/index.html