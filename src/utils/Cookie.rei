/**
 Given the session id key and cookie header string values extracts sessonId
 */
let getSessionId: (string, string) => option(string);

/**
 Extract sessionId from http cookie headers in [Req.t]
 */
let sessionIdOfReq: Req.t('sessionData) => option(string);