module Server = Server;
module Req = Req;
module Res = Res;
module Method = Method;
module QueryMap = Query.QueryMap;
module MimeTypes = MimeTypes;
module Session = Session;

open Lwt.Infix;
let listen = (port, serverConfig: Server.serverConfig('a)) => {
  let listenAddress = Unix.(ADDR_INET(inet_addr_loopback, port));
  let connectionHandler = Server.buildConnectionHandler(serverConfig);

  Lwt.async(() =>
    Lwt_io.establish_server_with_client_socket(
      listenAddress,
      connectionHandler,
    )
    >>= (
      _server => {
        serverConfig.onListen();
        Lwt.return_unit;
      }
    )
  );

  let (forever, _) = Lwt.wait();
  Lwt_main.run(forever);
};