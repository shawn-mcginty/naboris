/**
   Will start an http server listening at [inetAddr] on port [int] with [ServerConfig.t('sessionData)].
   */
let listen:
  (~inetAddr: Unix.inet_addr=?, int, ServerConfig.t('sessionData)) =>
  (Lwt.t('a), Lwt.u('a));

/**
   Same as [listen] but will specifically throw away the [Lwt.u('a)] and never resolve the promise.
   Keeping the server alive until the process is killed.
   */
let listenAndWaitForever:
  (~inetAddr: Unix.inet_addr=?, int, ServerConfig.t('sessionData)) =>
  Lwt.t('a);

/**
   Module with error handler types.
   */
module ErrorHandler = ErrorHandler;

/**
   Module for working with incoming requests.
   */
module Req = Req;

/**
   Module for creating and sending responses.
   */
module Res = Res;

/**
   Module to extract routing data.
   */
module Route = Route;

/**
   Module for configuring the naboris http server.
   */
module ServerConfig = ServerConfig;

/**
   Module for working with sessions and session data.
   */
module Session = Session;

/**
   Module with types used for matching requests.
   */
module Method = Method;

/**
   Module defining middleware functions.
 */
module Middleware = Middleware;

/**
   Module defining RequestHandler functions.
 */
module RequestHandler = RequestHandler;

/**
 Module with some utility functions for dates for HTTP headers.
 */
module DateUtils = DateUtils;

/**
   [Map] type for working with queries from routed requests.
   */
module Query = Query;

/** {b Less commonly used.}*/
module Cookie = Cookie;

/** {b Less commonly used.}*/
module MimeTypes = MimeTypes;

/** {b Less commonly used.}*/
module SessionManager = SessionManager;

/** {b Less commonly used.} */
module Router = Router;

/** {b Less commonly used.} */
module SessionConfig = SessionConfig;

/** {b Less commonly used.} */
module Etag = Etag;