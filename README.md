<img src="https://raw.githubusercontent.com/shawn-mcginty/naboris/master/docs-src/static/logos/logo-w-text.svg" height="36" alt="naboris" title="naboris">

Simple, fast, minimalist web framework for [OCaml](https://ocaml.org)/[ReasonML](https://reasonml.github.io) built on [httpaf](https://github.com/inhabitedtype/httpaf) and [lwt](https://github.com/ocsigen/lwt).

[https://naboris.dev](https://naboris.dev)

[![Build Status](https://travis-ci.com/shawn-mcginty/naboris.svg?branch=master)](https://travis-ci.com/shawn-mcginty/naboris)
[![opam version 0.1.3](https://img.shields.io/static/v1?label=opam&message=0.1.3&color=E7C162)](https://opam.ocaml.org/packages/naboris/)

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

> Pre `1.0.0` the API may be changing a bit. A list of these changes will be kept below.

## Contents
* [Installation](#installation)
* [Scaffolding](#scaffolding)
* [naboris.dev](https://naboris.dev)
* [Development](#development)
* [Breaking Changes](#breaking-changes)

### Installation

#### Note
Naboris makes heavy use of [Lwt](https://github.com/ocsigen/lwt#installing).  For better performance it is highly recommended _(however optional)_ to also install `conf-libev` which will configure [Lwt](https://github.com/ocsigen/lwt#installing) to run with the libev scheduler.  If you are using **esy** you will have to install `conf-libev` using a [special package](https://github.com/esy-packages/libev).

`conf-libev` also requires that the libev be installed.  This can usually be done via your package manager. 
```bash
brew install libev
```
or
```bash
apt install libev-dev
```

#### opam
```bash
opam install naboris
```

#### esy
```json
"@opam/naboris": "^0.1.3"
```

#### dune
```
(libraries naboris)
```

### Scaffolding
For a basic Reason project
```bash
git clone git@github.com:shawn-mcginty/naboris-re-scaffold.git
cd naboris-re-scaffold
npm run install
npm run build
npm run start
```

For a basic OCaml project
```bash
git clone git@github.com:shawn-mcginty/naboris-ml-scaffold.git
cd naboris-ml-scaffold
npm run install
npm run build
npm run start
```

## Development
Any help would be greatly appreciated! 👍

### To run tests

```bash
esy install
npm run test
```
[docs html index]: https://shawn-mcginty.github.io/naboris/docs/html/index.html

## Breaking Changes

| From | To | Breaking Change |
| --- | --- | --- |
| `0.1.2` | `0.1.3` | `secret` argument added to all session configuration APIs. |
| `0.1.0` | `0.1.1` | `ServerConfig.setSessionGetter` changed to `ServerConfig.setSessionConfig` which also allows `~maxAge` and `~sidKey` to be passed in optionally. |
| `0.1.0` | `0.1.1` | All `RequestHandler.t` and `Middleware.t` now return `Lwt.t(Res.t)` instead of `Lwt.t(unit)` |
| `0.1.0` | `0.1.1` | `Res.reportError` now taxes `exn` as the first argument to match more closely the rest of the `Res` API. |
