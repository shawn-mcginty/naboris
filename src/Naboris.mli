(** Will start an http server listening at [inetAddr] on port [int] with [ServerConfig.t('sessionData)]. *)
val listen :
  ?inetAddr:Unix.inet_addr -> int -> 'sessionData ServerConfig.t -> 'a Lwt.t * 'a Lwt.u

(** Same as [listen] but will specifically throw away the [Lwt.u('a)] and never resolve the promise.
    Keeping the server alive until the process is killed. *)
val listenAndWaitForever :
  ?inetAddr:Unix.inet_addr -> int -> 'sessionData ServerConfig.t -> 'a Lwt.t

(** Module with error handler types. *)
module ErrorHandler : module type of ErrorHandler

(** Module for working with incoming requests. *)
module Req : module type of Req

(** Module for creating and sending responses. *)
module Res : module type of Res

(** Module to extract routing data. *)
module Route : module type of Route

(** Module for configuring the naboris http server. *)
module ServerConfig : module type of ServerConfig

(** Module for working with sessions and session data. *)
module Session : module type of Session

(** Module with types used for matching requests. *)
module Method : module type of Method

(** Module defining middleware functions. *)
module Middleware : module type of Middleware

(** Module defining RequestHandler functions. *)
module RequestHandler : module type of RequestHandler

(** Module with some utility functions for dates for HTTP headers. *)
module DateUtils : module type of DateUtils

(** [Map] type for working with queries from routed requests. *)
module Query : module type of Query

(** {b Less commonly used.} *)
module Cookie : module type of Cookie

(** {b Less commonly used.} *)
module MimeTypes : module type of MimeTypes

(** {b Less commonly used.} *)
module SessionManager : module type of SessionManager

(** {b Less commonly used.} *)
module Router : module type of Router

(** {b Less commonly used.} *)
module SessionConfig : module type of SessionConfig

(** {b Less commonly used.} *)
module Etag : module type of Etag 