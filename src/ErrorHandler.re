type t = (exn, Route.t) => Lwt.t((list((string, string)), string));

type httpafErroHandler =
  (
    Unix.sockaddr,
    option(Httpaf.Response.t),
    Httpaf.Server_connection.error,
    Httpaf.Headers.t => Httpaf.Body.t([ | `write])
  ) =>
  unit;