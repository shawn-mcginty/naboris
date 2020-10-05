---
title: Error Handling
---

## Error Handling
Tips for handling errors nicely for the user.

- [Report Exception](#report-exception)
- [Error Handler](#error-handler)

#### <a name="report-exception" href="#report-exception">#</a> Report Exception
Sometimes an Exception (`exn`) will happen during the lifecycle of an http request/response. You may want to respond with specific http codes, in which case you should use the typical response functions. There is also a convenience function to report exceptions [`Res.report_error`](/odocs/naboris/Naboris/Res/index.html#val-report_error). Which will bypass the current request handler and instead apply the `error_handler` supplied when the naboris http server was created.

```reason
exception BadThing(string);

let startServer = () => {
  let port = 9000;
  let serverConfig = Naboris.ServerConfig.make()
    |> Naboris.ServerConfig.set_request_handler((route, req, res) =>
        switch (Naboris.Route.meth(route), Naboris.Route.path(route)) {
          | (GET, ["error"]) =>
            Naboris.Res.report_error(BadThing("something bad"), req, res)
          | _ =>
            Naboris.Res.status(404, res)
              |> Naboris.Res.text(req, "Not Found.");
        })
    |> Naboris.Server.set_error_handler((error, _route) => {
      let headers = [];
      let body = switch (error) {
        | BadThing(text) => text
        | _ => "Unknown Error"
      };
      // expects a promise of a tuple containing headers and the body string
      Lwt.return((headers, body));
    });

  Naboris.listen_and_wait_forever(port, serverConfig);
}

Lwt_main.run(startServer());
```
```ocaml
exception BadThing of string

let start_server ()=
  let port = 9000 in
  let server_config = Naboris.ServerConfig.make()
    |> Naboris.ServerConfig.set_request_handler(fun route req res ->
      match (Route.meth route, Route.path route) with
        | (GET, ["error"]) ->
          Naboris.Res.report_error (BadThing "") req res
        | _ ->
          Naboris.Res.status 404 res
            |> Naboris.Res.text req "Not Found.")
    |> Naboris.ServerConfig.set_error_handler(fun error route ->
      let headers = [] in
      let body = match (error) with
        | BadThing text -> text
        | _ -> "Unknown Error" in
      (* expects a promise of a tuple containing headers and the body string *)
      Lwt.return((headers, body))) in

  Naboris.listen_and_wait_forever port server_config

let _ = Lwt_main.run(main ())
```

#### <a name="error-handler" href="#error-handler">#</a> Error Handler
The above helper function [`Res.report_error`](/odocs/naboris/Naboris/Res/index.html#val-reportError) will respond to the current http request using the configured `error_handler`. This handler is provided by your [`ServerConfig.t`](/odocs/naboris/Naboris/ServerConfig) and is optional. By default it will respond with a `plain/text` type and a body containing the output of [`Printexc.to_string`](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Stdlib.Printexc.html) on the `exn` supplied.

> Note: This helper always responds with a `500` code.

Use [`ServerConfig.set_error_handler`](/odocs/naboris/Naboris/ServerConfig/#val-set_error_handler) and provide an [`ErrorHandler.t`](/odocs/naboris/Naboris/ErrorHandler/index.html).

```reason
// ServerConfig module
let set_error_handler: (ErrorHandler.t, t('sessionData)) => t('sessionData);
```
```ocaml
(* ServerConfig module *)
val set_error_handler : ErrorHandler.t -> 'sessionData t -> 'sessionData t
```

[`ErrorHandler.t`](/odocs/naboris/Naboris/ErrorHandler/index.html) is a function which takes as arguments the `exn` passed in to [`Res.report_error`](/odocs/naboris/Naboris/Res/index.html#val-reportError) and the [`Route.t`](/odocs/naboris/Naboris/Route/index.html) of the current request. It then expects a return value of an `Lwt` promise of a tuple of `(headers * body)`.  `headers` being a `(string * string) list` and body being a `string`.
```reason
// ErrorHandler module
type t = (exn, Route.t) => Lwt.t((list((string, string)), string));
```
```ocaml
(* ErrorHandler module *)
type t = exn -> Route.t -> ((string * string) list * string) Lwt.t
```
