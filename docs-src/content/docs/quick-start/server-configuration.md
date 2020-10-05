---
title: Server Configuration
---

## Server Configuration
There are a number of helper functions for building server config records.

- [Creating a Server Config](#creating-server-config)
- [Listen Callback](#listen-callback)
- [Request Handler](#request-handler)

#### <a name="creating-server-config" href="#creating-server-config">#</a> Creating a Server Config
[`ServerConfig.make`](/odocs/naboris/Naboris/ServerConfig/index.html#val-create) is used to generate a default server config object, this will be the starting point.
```reason
// ReasonML
let create: unit => ServerConfig.t('sessionData);
```
```ocaml
(* OCaml *)
val create: unit -> 'sessionData ServerConfig.t
```

#### <a name="listen-callback" href="#listen-callback">#</a> Listen Callback
[`ServerConfig.set_on_listen`](/odocs/naboris/Naboris/ServerConfig/index.html#val-set_on_listen) will set the function that will be called once the server has started and is listening for connections. The `on_listen` function has the type signature `unit -> unit`.
```reason
// ReasonML
let set_on_listen: (unit => unit, ServerConfig.t('sessionData)) => ServerConfig.t('sessionData)
```
```ocaml
(* OCaml *)
val set_on_listen: (unit -> unit) -> 'sessionData ServerConfig.t -> 'sessionData ServerConfig.t
```

#### <a name="request-handler" href="#request-handler">#</a> Request Handler
[`ServerConfig.set_request_handler`](/odocs/naboris/Naboris/ServerConfig/index.html#val-set_request_handler) will set the main request handler function on the config.  This function is the main entry point for http requests and usually where routing the request happens. The `request_handler` function has the type signature `Route.t -> 'sessionData Req.t -> Res.t -> Res.t Lwt.t`.
```reason
// ReasonML
let set_request_handler: (
  (Route.t, Req.t('sessionData), Res.t) => Lwt.t(Res.t),
  ServerConfig.t('sessionData)
) => ServerConfig.t('sessionData)
```
```ocaml
(* OCaml *)
val set_request_handler: (Route.t -> 'sessionData Req.t -> Res.t -> Res.t Lwt.t)
  -> 'sessionData ServerConfig.t -> 'sessionData ServerConfig.t
```