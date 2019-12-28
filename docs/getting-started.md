## Getting Started

### Configure the server
```ocaml
type mySession = {
  user: UserInfo
};

let sessionConfig: Naboris.Server.sessionConfig(mySession) = {
  onRequest: (sessionId) => {
    getSessionFromDbOrWhatever(sessionId)
      >>= (
        (mySessionData) => {
          Lwt.return(Naboris.Session(mySessionData));
        }
      );
  }
};

let testServerConfig: Naboris.Server.serverConfig(mySession) = {
  onListen: () => {
    print_string("🐫 Yay your server has started!\n");
  },
  sessionConfig: Some(sessionConfig),
  routeRequest: (route, req, res) =>
    switch (route.meth, route.path) {
    | (Naboris.Method.GET, ["echo", "pre-existing-route"]) =>
      Naboris.Res.status(200, res)
      |> Naboris.Res.html(
           req,
           "This route should take priority in the matcher.",
         );
      Lwt.return_unit;
    | (Naboris.Method.GET, ["html"]) =>
      Naboris.Res.status(200, res)
      |> Naboris.Res.html(
           req,
           "<!doctype html><html><body>You made it.</body></html>",
         );
      Lwt.return_unit;
    | (Naboris.Method.GET, ["echo-query", "query"]) =>
      echoQueryQuery(req, res, route.query);
      Lwt.return_unit;
    | (Naboris.Method.GET, ["echo", str]) =>
      Naboris.Res.status(200, res) |> Naboris.Res.html(req, str);
      Lwt.return_unit;
    | (Naboris.Method.GET, ["echo", str1, "multi", str2]) =>
      Naboris.Res.status(200, res)
      |> Naboris.Res.html(req, str1 ++ "\n" ++ str2);
      Lwt.return_unit;
    | (POST, ["echo"]) =>
      Lwt.bind(
        Naboris.Req.getBody(req),
        bodyStr => {
          Naboris.Res.status(200, res) |> Naboris.Res.html(req, bodyStr);
          Lwt.return_unit;
        },
      )
    | (GET, ["static", ...staticPath]) =>
      Naboris.Res.static(
        Sys.getcwd() ++ "/test/test_assets",
        staticPath,
        req,
        res,
      )
    | _ =>
      Naboris.Res.status(404, res)
      |> Naboris.Res.html(
           req,
           "<!doctype html><html><body>Page not found</body></html>",
         );
      Lwt.return_unit;
    },
};
```
`Naboris.Server.serverConfig('s)` - `'s` being your session data type.
- `onListen: unit -> unit` - Function callback that fires after the server has started.
- `sessionConfig: Some(Naboris.Server.sessionConfig('s))` - Hooks to attach your session data to the naboris request.
- `routeRequest: Naboris.Route.t -> Naboris.Req.t -> Naboris.Res.t -> Lwt.t(unit)` - Function that gets called on every request.  Use pattern matching to route and handle each request.

### Sessions
If the server config record includes a session config, the `onRequest` function will fire for each incoming request and attach the output to `Lwt.t(Req.session(s))` (`s` being your session data).

- `Naboris.Session.get(Naboris.Req.t) => Option('s)` - `'s` being the type of `s` returned by `onRequest` in the `sessionConfig('s)` record.

### Example without sessions
```ocaml
let testServerConfig: Naboris.Server.serverConfig(unit) = {
  onListen: () => {
    print_string("🐫 Yay your server has started!\n");
  },
  sessionConfig: None,
  routeRequest: (route, req, res) =>
    switch (route.meth, route.path) {
    | (Naboris.Method.GET, ["echo", "pre-existing-route"]) =>
      Naboris.Res.status(200, res)
      |> Naboris.Res.html(
           req,
           "This route should take priority in the matcher.",
         );
      Lwt.return_unit;
    | (Naboris.Method.GET, ["html"]) =>
      Naboris.Res.status(200, res)
      |> Naboris.Res.html(
           req,
           "<!doctype html><html><body>You made it.</body></html>",
         );
      Lwt.return_unit;
    | (Naboris.Method.GET, ["echo-query", "query"]) =>
      echoQueryQuery(req, res, route.query);
      Lwt.return_unit;
    | (Naboris.Method.GET, ["echo", str]) =>
      Naboris.Res.status(200, res) |> Naboris.Res.html(req, str);
      Lwt.return_unit;
    | (Naboris.Method.GET, ["echo", str1, "multi", str2]) =>
      Naboris.Res.status(200, res)
      |> Naboris.Res.html(req, str1 ++ "\n" ++ str2);
      Lwt.return_unit;
    | (POST, ["echo"]) =>
      Lwt.bind(
        Naboris.Req.getBody(req),
        bodyStr => {
          Naboris.Res.status(200, res) |> Naboris.Res.html(req, bodyStr);
          Lwt.return_unit;
        },
      )
    | (GET, ["static", ...staticPath]) =>
      Naboris.Res.static(
        Sys.getcwd() ++ "/test/test_assets",
        staticPath,
        req,
        res,
      )
    | _ =>
      Naboris.Res.status(404, res)
      |> Naboris.Res.html(
           req,
           "<!doctype html><html><body>Page not found</body></html>",
         );
      Lwt.return_unit;
    },
};
```

### Fire it up!

```ocaml
let portNumber = 9991;

Naboris.listen(portNumber, serverConfig);
```