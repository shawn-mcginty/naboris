type t('sessionData);

/**
 Get HttpAf request descriptor.
 */
let reqd: t('sessionData) => Httpaf.Reqd.t;

/**
 Get header from request.
 [None] if no matching header is found.
 */
let getHeader: (string, t('sessionData)) => option(string);


/**
 Get lwt promise of the body string from an http request.
 */
let getBody: t('sessionData) => Lwt.t(string);

/**
 Extracts ['sessionData] from request.

 Returns [None] if no session exists.
 */
let getSessionData: t('sessionData) => option('sessionData);

/**
 Sets ['sessionData] onto a request.
 */
let setSessionData: (option(Session.t('sessionData)), t('sessionData)) => t('sessionData);

/**
 {b Intended for internal use.}
 Creates default req record.
 */
let fromReqd: Httpaf.Reqd.t => t('sessionData);