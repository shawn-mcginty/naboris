---
title: Basic Server
---

> All Quick Start examples will use **esy** and **dune** for dependency management and build. These are _not requirements_ of naboris.

## Basic Server
An http server with minimal configuration.

- [Project Structure](#project-structure)
- [Esy package.json](#esy-package-json)
- [Dune files](#dune-files)
- [App Code](#app-code)
- [Build and Run](#build-and-run)

#### <a name="project-structure" href="#project-structure">#</a> Project Structure
For this example we will assume the project directory structure looks something like this:

```
  root-project-directory/
  ├── lib/
  │   ├── dune
  │   └── App.re  # or App.ml for ocaml
  ├── dune-project
  └── package.json
```

#### <a name="esy-package-json" href="#esy-package-json">#</a> Esy package.json
If you are unfamiliar with [esy](https://esy.sh) it is a
dependency management tool for OCaml projects. It uses a workflow
similar to [npm](https://npmjs.com) in the Node.js world.

Start with a very simple `package.json` file:
```json
{
  "name": "App",
  "version": "0.0.1",
  "description": "Basic naboris example server",
  "esy": {
    "build": [
      "dune build -p #{self.name}"
    ],
    "buildInSource": "_build"
  },
  "scripts": {
    "install": "esy install",
    "build": "esy b dune build @install",
    "clean": "esy b dune clean"
  },
  "dependencies": {
    "@opam/dune": "*",
    "@opam/lwt": ">=5.1.1",
    "@opam/naboris": "*"
  },
  "devDependencies": {
    "esy": "^0.5.6",
    "ocaml": "~4.7",
    "reason-cli": ">=3.3.3"
  },
  "peerDependencies": {
    "ocaml": ">=4.7.0"
  }
}
```

#### <a name="dune-files" href="#dune-files">#</a> Dune Files
If you are unfamiliar with [dune](https://dune.build/) it is a very commonly
used build tool for native OCaml and ReasonML projects.

Our project need two dune files one at the project root called `dune-project`:
```lisp
(lang dune 1.6)
(name app)
```

And one in the `lib` folder with our other source files called `dune`:
```lisp
(executable
	(name app)
	(libraries lwt naboris)
)
```

#### <a name="app-code" href="#app-code">#</a> App Code

```reason
/* lib/App.re */
let startServer = () => {
  let port = 9000;
  let serverConfig = Naboris.ServerConfig.create()
    |> Naboris.ServerConfig.setRequestHandler((route, req, res) =>
        switch (Naboris.Route.meth(route), Naboris.Route.path(route)) {
          | (GET, [""]) =>
            Naboris.Res.status(200, res)
              |> Naboris.Res.text(req, "Hello world!");
          | _ =>
            Naboris.Res.status(404, res)
              |> Naboris.Res.text(req, "Not Found.");
        });

  Naboris.listenAndWaitForever(port, serverConfig);
}

Lwt_main.run(startServer());
```
```ocaml
(* lib/App.ml *)
let start_server ()=
  let port = 9000 in
  let server_config = Naboris.ServerConfig.create()
    |> Naboris.ServerConfig.setRequestHandler(fun route req res ->
      match (Route.meth route, Route.path route) with
        | (GET, [""]) ->
          Naboris.Res.status 200 res
            |> Naboris.Res.text req "Hello world!"
        | _ ->
          Naboris.Res.status 404 res
            |> Naboris.Res.text req "Not Found.") in

  Naboris.listenAndWaitForever port server_config

let _ = Lwt_main.run(main ())
```

#### <a name="build-and-run" href="#build-and-run">#</a> Build and Run

```bash
$ esy install # install all required dependencies
$ esy b dune build lib/App.exe # build the app
$ esy b dune exec lib/App.exe # run the app
```
