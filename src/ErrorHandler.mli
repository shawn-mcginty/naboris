(** Called when [Res.reportError] is called. Expects return values
    of an [Lwt.t] promise containing a tuple of [headers] ([(string * string) list]) and
    [response_body] ([string]). *)
type t = exn -> Route.t -> ((string * string) list * string) Lwt.t 