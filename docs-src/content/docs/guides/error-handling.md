---
title: Error Handling
---

## Error Handling
Tips for handling errors nicely for the user.

- [Report Exception](#report-exception)
- [Error Handler](#error-handler)

#### <a name="report-exception" href="#report-exception">#</a> Report Exception
Sometimes an Exception (`exn`) will happen during the lifecycle of an http request/response. You may want to respond with specific http codes, in which case you should use the typical response functions. There is also a convenience function to report exceptions [`Res.reportException`](/odocs/naboris/Naboris/Res/index.html#val-reportError). Which will bypass the current request handler and instead apply the `errorHandler` supplied when the naboris http server was created.

```reason
exception BadThing of string;

let startServer = () => {
  let port = 9000;
  let serverConfig = Naboris.ServerConfig.create()
    |> Naboris.ServerConfig.setRequestHandler((route, req, res) =>
        switch (Naboris.Route.meth(route), Naboris.Route.path(route)) {
          | (GET, ["error"]) =>
            Naboris.Res.reportException(BadThing("something bad"), req, res)
          | _ =>
            Naboris.Res.status(404, res)
              |> Naboris.Res.text(req, "Not Found.");
        });

  Naboris.listenAndWaitForever(port, serverConfig);
}

Lwt_main.run(startServer());
```