/**
 Create a new session with ['sessionData] and add cookie headers to [Res.t].  Returns newly created session id [string].
 */
let startSession: (Req.t('sessionData), Res.t, 'sessionData) => (Req.t('sessionData), Res.t, string);

/**
 Sets headers on `Res.t` to expire the session.
 */
let removeSession: (Req.t('sessionData), Res.t) => Res.t;

/**
 {b Intended for internal use.}

 Applies [mapSession] from config to request which uses the session id from the request cookies.
 Returns promise of a new request with session data available if it was found.
 */
let resumeSession: (ServerConfig.t('sessionData), Req.t('sessionData)) => Lwt.t(Req.t('sessionData));

/**
 {b Intended for internal use.}
 */
let generateSessionId: unit => string;

/**
 {b Intended for internal use.}
 */
let sign: (string, string) => string;

/**
 {b Intended for internal use.}
 */
let unsign: (string, string) => option(string);