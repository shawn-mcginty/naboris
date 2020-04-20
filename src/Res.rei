type t;

/**
 Creates a default response record with empty headers and a 200 status.
 */
let default: unit => t;

/**
 Creates new response from input response with status of [int].
 */
let status: (int, t) => t;

/**
 Sends response [t] with body [string].
 Adding headers [Content-type: application/json] and [Content-length]

 {e This function will end the http request/response lifecycle.}
 */
let json: (Req.t('sessionData), string, t) => Lwt.t(t);

/**
 Sends response [t] with body [string].
 Adding headers [Content-type: text/html] and [Content-length]

 {e This function will end the http request/response lifecycle.}
 */
let html: (Req.t('sessionData), string, t) => Lwt.t(t);

/**
 Sends response [t] with body [string].
 Adding headers [Content-type: text/plain] and [Content-length]

 {e This function will end the http request/response lifecycle.}
 */
let text: (Req.t('sessionData), string, t) => Lwt.t(t);

/**
 Sends response [t] with body [string].

 {e This function will add [Content-length] header with the length of [string].}
 {e This function will add [Connection: keep-alive] header.}
 {e This function will end the http request/response lifecycle.}
 */
let raw: (Req.t('sessionData), string, t) => Lwt.t(t);

/**
 Creates a [Lwt_io.channel(Output)] which can be written to to stream data to the client.
 And a [Lwt.t(t)] promise, which will resolve when the output channel is closed.
 This will set [Transfer-Encoding: chunked] header and follow the protocol for chunked responses.
 */
let writeChannel:
  (Req.t('a), t) => (Lwt_io.channel(Lwt_io.output), Lwt.t(t));

/**
 Creates new response from [t] with header [(string, string)] added.
 */
let addHeader: ((string, string), t) => t;

/**
 Opens file starting at path [string] and following [list(string)].
 Sets [Content-type] header based on file extension.  If type cannot be inferred [text/plain] is used.
 Sets [Content-length] header with the size of the file in bytes.
 Responds with [404] if file does not exist.

 {e This function will end the http request/response lifecycle.}
 */
let static: (string, list(string), Req.t('sessionData), t) => Lwt.t(t);

/**
 Sets [Location] header to [string] and responds with [302].
 Redirecting client to [string].
 */
let redirect: (string, Req.t('sessionData), t) => Lwt.t(t);

/**
 Report an error [exn] by executing [error_handler] from your [Naboris.ServerConfig].

 {e This function will create a new [Res] and any headers on the current [Res] will be lost.}
 */
let reportError: (exn, Req.t('sessionData), t) => Lwt.t(t);

/**
 Adds [Set-Cookie] header to response [t] with
 [string] sessionId
 [string] cookie key
 [int] max age of cookie in seconds

 {e These will be configurable in future versions.}
 */
let setSessionCookies: (string, string, int, t) => t;