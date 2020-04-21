---
title: Sessions
---

## Sessions
Managing sessions in naboris.

- [Session Data](#session-data)
- [Session Config](#session-config)
- [Session Mapping](#session-mapping)
- [Starting Sessions](#starting-sessions)
- [Invalidate Sessions](#invalidate-sessions)

#### <a name="session-data" href="#session-data">#</a> Session Data
Many `Naboris` types take the parameter `'sessionData` this represents a custom data type that will define session data that will be attached to an incoming request.

#### <a name="session-config" href="#session-config">#</a> Session Config
[`ServerConfig.setSessionConfig`](/odocs/naboris/Naboris/ServerConfig/index.html#val-setSessionConfig) will return a new server configuration with the desired
session configuration. This call consists of one required argument `mapSession` and two
optional arguments `~maxAge` and `~sidKey`.

```reason
let setSessionConfig: (~maxAge: int=?, ~sidKey: string=?, option(string) => Lwt.t(option(Session.t('sessionData))), ServerConfig.t('sessionData)) => ServerConfig.t('sessionData);
```
```ocaml
val setSessionConfig: ?maxAge: int -> ?sidKey: string -> string option -> 'sessionData Session.t option Lwt.t -> 'sessionData ServerConfig.t -> 'sessionData ServerConfig.t
```

* `sidKey` - `string` (optional) - The key used to store the session id in browser cookies. Defaults to `"nab.sid"`.
* `maxAge` - `int` (optional) - The max age of session cookies in seconds.  Defaults to `2592000` (30 days.)
* `mapSession` - covered in the section below.

#### <a name="session-mapping" href="#session-mapping">#</a> Session Mapping
`mapSession` is a special function that is used to set session data on an incoming request based on the requests cookies. The signature looks like: `option(string) => Lwt.t(option(Naboris.Session.t('sessionData)))`.  That's a complicated type signature that expresses that the request may or may not have a `sessionId`; and given that fact it may or may not return a session.
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
  |> Naboris.ServerConfig.setSessionConfig(sessionId => switch(sessionId) {
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
  userId: int;
  username: string;
  first_name: string;
  last_name: string;
  is_admin: bool
}

let serverConfig: user_data Naboris.ServerConfiguserData = Naboris.ServerConfig.create ()
  |> Naboris.ServerConfig.setSessionConfig (fun session_id ->
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
            userId= 1;
            username= "foo";
            first_name= "foo";
            last_name= "bar";
            is_admin= false
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

#### <a name="starting-sessions" href="#starting-sessions">#</a> Starting Sessions
[`SessionManager.startSession`](/odocs/naboris/Naboris/SessionManager/index.html#val-startSession) generates a new session id `string` value and adds `Set-Cookie` header to a new `Res.t`. Useful for handling a login request.

```reason
let startSession: (Req.t('sessionData), Res.t, 'sessionData) => (Req.t('sessionData), Res.t, string);
```
```ocaml
val startSession: 'sessionData Req.t -> Res.t -> 'sessionData -> 'sessionData Req.t * Res.t * string
```

An example login request might look like this:

```reason
| (Naboris.Method.POST, ["login"]) =>
  let (req2, res2, _sid) =
    Naboris.SessionManager.startSession(
      req,
      res,
      TestSession.{username: "realsessionuser"},
    );
  Naboris.Res.status(200, res2) |> Naboris.Res.text(req2, "OK");
```
```ocaml
| (Naboris.Method.POST, ["login"]) ->
  let (req2, res2, _sid) = Naboris.SessionManager.startSession
    req
    res
    TestSession.{username= "realsessionuser"} in
  (Naboris.Res.status 200 res2) |> Naboris.Res.text req2 "OK"
```

#### <a name="invalidate-sessions" href="#invalidate-sessions">#</a> Invalidate Sessions
[`SessionManager.removeSession`](/odocs/naboris/Naboris/SessionManager/index.html#val-removeSession) adds `Set-Cookie` header to a new `Res.t` to expire the session id cookie. Useful for handling a logout request.

```reason
let removeSession: (Req.t('sessionData), Res.t) => Res.t;
```
```ocaml
val removeSession: 'sessionData Req.t -> Res.t -> Res.t
```

An example logout request might look like this:

```reason
| (Naboris.Method.GET, ["logout"]) =>
  Naboris.SessionManager.removeSession(req, res)
    |> Naboris.Res.status(200)
    |> Naboris.Res.text(req, "OK");
```
```ocaml
| (Naboris.Method.GET, ["logout"]) ->
  Naboris.SessionManager.removeSession req res
    |> Naboris.Res.status 200
    |> Naboris.Res.text req "OK";
```