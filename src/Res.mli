type t

(** Creates a default response record with empty headers and a 200 status. *)
val default : unit -> t

(** Creates new response from input response with status of [int]. *)
val status : int -> t -> t

(** Sends response [t] with body [string].
    Adding headers [Content-type: application/json] and [Content-length]

    {e This function will end the http request/response lifecycle.} *)
val json : 'sessionData Req.t -> string -> t -> t Lwt.t

(** Sends response [t] with body [string].
    Adding headers [Content-type: text/html] and [Content-length]

    {e This function will end the http request/response lifecycle.} *)
val html : 'sessionData Req.t -> string -> t -> t Lwt.t

(** Sends response [t] with body [string].
    Adding headers [Content-type: text/plain] and [Content-length]

    {e This function will end the http request/response lifecycle.} *)
val text : 'sessionData Req.t -> string -> t -> t Lwt.t

(** Sends response [t] with body [string].

    {e This function will add [Content-length] header with the length of [string].}
    {e This function will add [Connection: keep-alive] header.}
    {e This function will end the http request/response lifecycle.} *)
val raw : 'sessionData Req.t -> string -> t -> t Lwt.t

(** Creates a [Lwt_io.channel(Output)] which can be written to to stream data to the client.
    And a [Lwt.t(t)] promise, which will resolve when the output channel is closed.
    This will set [Transfer-Encoding: chunked] header and follow the protocol for chunked responses. *)
val writeChannel : 'a Req.t -> t -> (Lwt_io.output Lwt_io.channel * t Lwt.t)

(** Creates new response from [t] with header [(string, string)] added. *)
val addHeader : (string * string) -> t -> t

(** Opens file starting at path [string] and following [string list].
    Sets [Content-type] header based on file extension.  If type cannot be inferred [text/plain] is used.
    Sets [Content-length] header with the size of the file in bytes.
    Responds with [404] if file does not exist.

    {e This function will end the http request/response lifecycle.} *)
val static : string -> string list -> 'sessionData Req.t -> t -> t Lwt.t

(** Sets [Location] header to [string] and responds with [302].
    Redirecting client to [string]. *)
val redirect : string -> 'sessionData Req.t -> t -> t Lwt.t

(** Report an error [exn] by executing [error_handler] from your [Naboris.ServerConfig].
    Final response code is always [500].

    {e This function will create a new [Res] and any headers on the current [Res] will be lost.} *)
val reportError : exn -> 'sessionData Req.t -> t -> t Lwt.t

(** Adds [Set-Cookie] header to response [t] with
    [string] sessionId
    [string] cookie key
    [int] max age of cookie in seconds

    {e These will be configurable in future versions.} *)
val setSessionCookies : string -> string -> int -> t -> t 