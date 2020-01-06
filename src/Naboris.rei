  /**
   * Will start an http server listening on `inetAddr` at port `int` with `ServerConfig.t('sessionData)`
   */
  let listen: (~inetAddr: Unix.inet_addr=?, int, ServerConfig.t('sessionData)) => (Lwt.t('a), Lwt.u('a));

  /**
   * Same as `listen` but will specifically throw away the `Lwt.u('a)` and never resolve the promise.
   * Keeping the server alive until the process is killed.
   */
  let listenAndWaitForever: (~inetAddr: Unix.inet_addr=?, int, ServerConfig.t('sessionData)) => Lwt.t('a);

  module Cookie = Cookie;
  module Method = Method;
  module Router = Router;
  module QueryMap = Query.QueryMap;
  module MimeTypes = MimeTypes;
  module Req = Req;
  module Res = Res;
  module ServerConfig = ServerConfig;
  module Session = Session;
  module SessionManager = SessionManager;