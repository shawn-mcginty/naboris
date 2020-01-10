/**
 {b Intended for internal use.}

 Create a new sessino with ['sessionData] and add cookie headers to [Res.t].  Returns newly created session id [string].
 */
let startSession: (Req.t('sessionData), Res.t, 'sessionData) => (Req.t('sessionData), Res.t, string);

/**
 {b Intended for internal use.}

 Applies [sessionGetter] from config to request which uses the session id from the request cookies.
 Returns promise of a new request with session data available if it was found.
 */
let resumeSession: (ServerConfig.t('sessionData), Req.t('sessionData)) => Lwt.t(Req.t('sessionData));