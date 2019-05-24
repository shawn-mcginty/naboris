module Req = Req;
module Res = Res;
module Router = Router;

type serverConfig = {
  onListen: unit => unit,
  routeRequest: (Route.t, Req.t, Res.t) => Lwt.t(unit),
};

let respondWithDefault = requestDescriptor => {
  let response =
    Httpaf.Response.create(
      ~headers=
        Httpaf.Headers.of_list([
          ("Content-Type", "text/plain"),
          ("Connection", "close"),
        ]),
      `Not_found,
    );

  let response_body =
    Httpaf.Reqd.respond_with_streaming(requestDescriptor, response);

  let respond = () =>
    Httpaf.Body.write_string(response_body, "Page not found.");

  respond();
};

let buildConnectionHandler = serverConfig => {
  let request_handler =
      (_client_address: Unix.sockaddr, request_descriptor: Httpaf.Reqd.t) => {
    let request: Httpaf.Request.t = Httpaf.Reqd.request(request_descriptor);
    let target = request.target;
    let method = Method.ofHttpAfMethod(request.meth);
    let route = Router.generateRoute(target, method);

    let _promise =
      serverConfig.routeRequest(
        route,
        Req.fromReqd(request_descriptor),
        Res.default(),
      );
    ();
  };

  let error_handler =
      (_client_address: Unix.sockaddr, ~request as _=?, error, start_response) => {
    let response_body = start_response(Httpaf.Headers.empty);

    switch (error) {
    | `Exn(exn) =>
      Httpaf.Body.write_string(response_body, Printexc.to_string(exn));
      Httpaf.Body.write_string(response_body, "\n");

    | #Httpaf.Status.standard as error =>
      Httpaf.Body.write_string(
        response_body,
        Httpaf.Status.default_reason_phrase(error),
      )
    };

    Httpaf.Body.close_writer(response_body);
  };

  Httpaf_lwt_unix.Server.create_connection_handler(
    ~config=?None,
    ~request_handler,
    ~error_handler,
  );
};