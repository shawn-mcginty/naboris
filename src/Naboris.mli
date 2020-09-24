val listen :
  ?inet_addr:Unix.inet_addr ->
  int ->
  'sessionData ServerConfig.t ->
  'a Lwt.t * 'a Lwt.u
(**
  Will start an http server listening at [inet_addr] on port [int] with ['sessionData ServerConfig.t].
 *)

val listen_and_wait_forever :
  ?inet_addr:Unix.inet_addr -> int -> 'sessionData ServerConfig.t -> 'a Lwt.t
(**
  Same as [listen] but will specifically throw away the ['a Lwt.u] and never resolve the promise.
  Keeping the server alive until the process is killed.
 *)

module ErrorHandler = ErrorHandler
(**
  Module with error handler types.
 *)

module Req = Req
(**
  Module for working with incoming requests.
 *)

module Res = Res
(**
  Module for creating and sending responses.
 *)

module Route = Route
(**
  Module to extract routing data.
 *)

module ServerConfig = ServerConfig
(**
  Module for configuring the naboris http server.
 *)

module Session = Session
(**
  Module for working with sessions and session data.
 *)

module Method = Method
(**
  Module with types used for matching requests.
 *)

module Middleware = Middleware
(**
  Module defining middleware function signatures.
 *)

module RequestHandler = RequestHandler
(**
  Module defining RequestHandler function signatures.
 *)

module DateUtils = DateUtils
(**
  Module with some utility function for dates for http headers.
 *)

module Query = Query
(**
  [Map] type for working with queries from routed requests
 *)

module Cookie = Cookie
(**
  {b Intended for internal use. Made public if needed but should be used less commonly.}
 *)

module MimeTypes = MimeTypes
(**
  {b Intended for internal use. Made public if needed but should be used less commonly.}
 *)

module SessionManager = SessionManager
(**
  {b Intended for internal use. Made public if needed but should be used less commonly.}
 *)

module Router = Router
(**
  {b Intended for internal use. Made public if needed but should be used less commonly.}
 *)

module SessionConfig = SessionConfig
(**
  {b Intended for internal use. Made public if needed but should be used less commonly.}
 *)

module Etag = Etag
(**
  {b Intended for internal use. Made public if needed but should be used less commonly.}
 *)
