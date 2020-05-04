type t('sessionData) = {
  getSession: option(string) => Lwt.t(option(Session.t('sessionData))),
  sidKey: string,
  maxAge: int,
  secret: string,
};

/**
 Returns key to be used for session cookies.
 */
let sidKey: option(t('sessionData)) => string;

/**
 Returns max age to be used for session cookies.
 */
let maxAge: option(t('sessionData)) => int;

/**
 Returns secret used to sign session id cookies.
 */
let secret: option(t('sessionData)) => string;