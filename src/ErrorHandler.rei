/**
 Called when [Res.reportError] is called. Expects return values
 of an [Lwt.t] promise containing a tuple of [headers] ([list(string * string)]) and
 [response_body] ([string]).
 */
type t = (exn, Route.t) => Lwt.t((list((string, string)), string));