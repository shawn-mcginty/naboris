module Server = Server;

open Lwt.Infix;
let listen = (port, server: Server.server) => {
  let listenAddress = Unix.(ADDR_INET(inet_addr_loopback, port));
  let connectionHandler = Server.buildConnectionHandler(server);

	Lwt.async(() =>
		Lwt_io.establish_server_with_client_socket(
			listenAddress,
			connectionHandler,
		)
		>>= (
			_server => {
				server.onListen();
				Lwt.return_unit;
      }
    )
  );

  let (forever, _) = Lwt.wait();
  Lwt_main.run(forever);
};