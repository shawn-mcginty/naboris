type t = (
  Unix.sockaddr,
  option(Httpaf.Response.t),
  Httpaf.Server_connection.error,
  Httpaf.Headers.t => Httpaf.Body.t([ `write ])
) => unit;