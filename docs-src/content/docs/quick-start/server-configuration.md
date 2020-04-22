---
title: Server Configuration
---

## Server Configuration
There are a number of helper functions for building server config records.

- [Creating a Server Config](#creating-server-config)
- [Listen Callback](#listen-callback)
- [Request Handler](#request-handler)

#### <a name="creating-server-config" href="#creating-server-config">#</a> Creating a Server Config
[`ServerConfig.create`](/odocs/naboris/Naboris/ServerConfig/index.html#val-create) is used to generate a default server config object, this will be the starting point.
```reason
// ReasonML
let create: unit => ServerConfig.t('sessionData);
```
```ocaml
(* OCaml *)
val create: unit -> 'sessionData ServerConfig.t
```

#### <a name="listen-callback" href="#listen-callback">#</a> Listen Callback
[`ServerConfig.setOnListen`](/odocs/naboris/Naboris/ServerConfig/index.html#val-setOnListen) will set the function that will be called once the server has started and is listening for connections.  The `onListen` function has the type signature `unit => unit`.
```reason
// ReasonML
let setOnListen: (unit => unit, ServerConfig.t('sessionData)) => ServerConfig.t('sessionData)
```
```ocaml
(* OCaml *)
val setOnListen: (unit -> unit) -> 'sessionData ServerConfig.t -> 'sessionData ServerConfig.t
```

#### <a name="request-handler" href="#request-handler">#</a> Request Handler
[`ServerConfig.setRequestHandler`](/odocs/naboris/Naboris/ServerConfig/index.html#val-setRequestHandler) will set the main request handler function on the config.  This function is the main entry point for http requests and usually where routing the request happens.  The `requestHandler` function has the type signature `(Route.t, Req.t('sessionData), Res.t) => Lwt.t(Res.t)`.
```reason
// ReasonML
let setRequestHandler: (
  (Route.t, Req.t('sessionData), Res.t) => Lwt.t(Res.t),
  ServerConfig.t('sessionData)
) => ServerConfig.t('sessionData)
```
```ocaml
(* OCaml *)
val setRequestHandler: (Route.t -> 'sessionData Req.t -> Res.t -> Res.t Lwt.t)
  -> 'sessionData ServerConfig.t -> 'sessionData ServerConfig.t
```