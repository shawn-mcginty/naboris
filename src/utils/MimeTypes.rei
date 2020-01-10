/**
 Exposed only for unit testing
 */
let getExtension: string => string;

/**
 Given a filename returns content type.
 Defaults to ["text/plain"] if type cannot be inferred.
 */
let getMimeType: string => string;