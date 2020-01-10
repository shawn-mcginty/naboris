type t('sessionData);

/**
 Creates new [t('sessionData)] with id of [string].
 */
let create: (string, 'sessionData) => t('sessionData);

/**
 Return session data of given [t('sessionData)].
 */
let data: t('sessionData) => 'sessionData;

/**
 Return session id of given [t('sessionData)].
 */
let id: t('sessionData) => string;