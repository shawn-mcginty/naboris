(** Given the session id key and cookie header string values extracts sessonId *)
val getSessionId : string -> string -> string option

(** Extract sessionId from http cookie headers in [Req.t] *)
val sessionIdOfReq : 'sessionData Req.t -> string option 