type 'sessionData t =
  'sessionData RequestHandler.t ->
  Route.t ->
  'sessionData Req.t ->
  Res.t ->
  Res.t Lwt.t
(**
  Middleware function signature.
 *)