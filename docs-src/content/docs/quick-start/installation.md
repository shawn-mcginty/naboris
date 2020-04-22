---
title: Installation
---

> During the time of this writing naboris has not been tested on **Windows**.

## Installation
How to install naboris.

- [Requirements](#requirements)
- [Scaffolding](#scaffolding)
- [Opam](#opam)
- [Dune](#dune)
- [Esy](#esy)
- [Libev](#libev)

#### <a name="requirements" href="#requirements">#</a> Requirements

- **OCaml** - `>= 4.07.1`
- **Lwt** - `>= 5.1.1`

###### Optional requirements
Naboris makes heavy use of `Lwt` promises. For best performance
it is recommended (per [the Lwt documentation](https://ocsigen.org/lwt/5.1.1/manual/manual))
to install `libev` and use the `conf-libev` opam package. Read more about it [below](#libev).

#### <a name="scaffolding" href="#scaffolding">#</a> Scaffolding
For an easy way to get a server up and running there are scaffolding projects available on
GitHub. These projects use [esy](https://esy.sh) to sandbox opam and build. This means
`node.js` is required to run these projects as is.

OCaml:
```bash
$ git clone git@github.com:shawn-mcginty/naboris-ocaml-scaffold.git
$ npm run install
$ npm run build
$ npm run start
```

ReasonML:
```bash
$ git clone git@github.com:shawn-mcginty/naboris-re-scaffold.git
$ npm run install
$ npm run build
$ npm run start
```

#### <a name="opam" href="#opam">#</a> Opam
naboris is available on `opam`

```bash
$ opam install naboris
```

#### <a name="dune" href="#dune">#</a> Dune
```lisp
(libraries naboris)
```

#### <a name="esy" href="#esy">#</a> Esy
```json
  "dependencies": {
    "@opam/naboris": "*",
  }
```

_If you're using esy please read the libev section._

#### <a name="libev" href="#libev">#</a> Libev
It is highly recommended to install `libev` and use the `conf-libev` opam package
which will configure `lwt` to run using the `libev` scheduler.

`libev` can most likely be installed using your package manager.

e.g. homebrew
```bash
$ brew install libev
```

e.g. apt
```bash
$ sudo apt-get update
$ sudo apt-get install libev-dev
```

Check out the [libev homepage](http://software.schmorp.de/pkg/libev.html) for more info.

`conf-libev` can be installed via opam

Opam:
```bash
$ opam install conf-libev
```


If you use **esy** for sandboxing you'll have to use a special resolution:
```json
  "resolutions": {
    "@opam/conf-libev": "esy-packages/libev:package.json#0b5eb66"
  }
```

_Notes about esy custom resolution: This is pegged to a specific commit. At the time of this writing the commit listed above worked great. You may need to check the [GitHub repo](https://github.com/esy-packages/libev) and switch to a fresher commit._