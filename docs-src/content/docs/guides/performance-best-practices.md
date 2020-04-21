---
title: Performance Best Practices
---

## Performance Best Practices
Best practices for enhanced performance.

- [Libev](#libev)
- [Static Files](#static-files)

### <a name="libev" href="#libev">#</a> Libev
[Lwt](https://ocsigen.org/lwt) promises are used heavily by naboris. [Lwt](https://ocsigen.org/lwt) uses a scheduler underneath the hood to keep promises pausing and resuming as needed. If available it is highly recommended to use [libev](http://software.schmorp.de/). This can easily be done by installing [libev](http://software.schmorp.de/) on the host system and including [`conf-libev`](https://opam.ocaml.org/packages/conf-libev/) in the `opam` environment used to run naboris.

The [installation page](http://localhost:3999/quick-start/installation#libev) has more info on installing libev.

### <a name="static-files" href="#static-files">#</a> Static Files
It is highly recommended that static files be [served via a reverse proxy such as nginx](https://docs.nginx.com/nginx/admin-guide/web-server/serving-static-content/). These servers are highly optimized and configurable for serving static files in ways that naboris would take much more work to achieve.