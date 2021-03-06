---
title: Templating Engines
---


## Templating Engines
Example usage of HTML templating engines with naboris.

- [Basics](#basics)
- [Full Example](#full-example)

#### <a name="basics" href="#basics">#</a> Basics
At the end of the day templating engines are just functions which return a `string`. This makes it much easier to create dynamic HTML documents generated by your server. There can be many implementations of this but usually you will define a **template** and use some data structure to augment that template. The result of all of this will be a partial or complete document which then you can server to the user.

Some libraries for templating:
* [Jingoo](https://github.com/tategakibunko/jingoo)
* [Mustache](https://github.com/rgrinberg/ocaml-mustache)
* [TyXML](https://github.com/ocsigen/tyxml)

#### <a name="full-example" href="#full-example">#</a> Full Example
Here is a very small example of a `requestHandler` using [Mustache](https://github.com/rgrinberg/ocaml-mustache) to create a dynamic HTML document

```reason
let template = Mustache.of_string("<!doctype html>
<html>
  <title>{{pageName}}</title>
</html>
<body>
  <h2>Welcome to {{pageName}} page</h2>
</body>
</html>");

let startServer = () => {
  let port = 9000;
  let serverConfig = Naboris.ServerConfig.create()
    |> Naboris.ServerConfig.setRequestHandler((route, req, res) =>
        switch (Naboris.Route.meth(route), Naboris.Route.path(route)) {
          | (GET, [pageName]) =>
            let json = `O([("pageName", `String(pageName))]);
            let html = Mustache.render(template, json);
            Naboris.Res.status(200, res)
              |> Naboris.Res.html(req, html);
          | _ =>
            Naboris.Res.status(404, res)
              |> Naboris.Res.text(req, "Not Found.");
        });

  Naboris.listenAndWaitForever(port, serverConfig);
}

Lwt_main.run(startServer());
```
```ocaml
let template = Mustache.of_string "<!doctype html>\
<html>\
  <title>{{page_name}}</title>\
</html>\
<body>\
  <h2>Welcome to {{page_name}} page</h2>\
</body>\
</html>"

let start_server ()=
  let port = 9000 in
  let server_config = Naboris.ServerConfig.create()
    |> Naboris.ServerConfig.setRequestHandler(fun route req res ->
      match (Naboris.Route.meth route, Naboris.Route.path route) with
        | (GET, [page_name]) ->
          let json = `O [ ("page_name", `String page_name) ] in
          let html = Mustache.render template json in
          Naboris.Res.status 200 res
            |> Naboris.Res.html req html
        | _ ->
          Naboris.Res.status 404 res
            |> Naboris.Res.text req "Not Found.") in

  Naboris.listenAndWaitForever port server_config

let _ = Lwt_main.run(start_server ())
```

Visiting `http://localhost:9000/:pageName` will render an html document with the parameter from the path.