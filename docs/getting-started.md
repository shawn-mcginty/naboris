## Getting Started

### Configure the server
```ocaml
let testServerConfig: Naboris.Server.serverConfig = {
  onListen: () => {
    print_string("🐫 Yay your server has started!\n");
  },
  routeRequest: (route, req, res) =>
    switch (route.method, route.path) {
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

- `onListen: unit -> unit` - Function callback that fires after the server has started.
- `routeRequest: Naboris.Route.t -> Naboris.Req.t -> Naboris.Res.t -> Lwt.t(unit)` - Function that gets called on every request.  Use pattern matching to route and handle each request.

### Fire it up!

```ocaml
let portNumber = 9991;

Naboris.listen(portNumber, serverConfig);
```