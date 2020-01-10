/**
 * Given a Cookie header string value extracts sessonId
 */
let getSessionId: string => option(string);

/**
 * Extract sessionId from http cookie headers in `Req.t`
 */
let sessionIdOfReq: Req.t('sessionData) => option(string);