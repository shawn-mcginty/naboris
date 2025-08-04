module Server = Server
module Req = Req
module Res = Res
module Method = Method
module Route = Route
module Router = Router
module Query = Query
module MimeTypes = MimeTypes
module Middleware = Middleware
module RequestHandler = RequestHandler
module Session = Session
module SessionManager = SessionManager
module Cookie = Cookie
module ServerConfig = ServerConfig
module SessionConfig = SessionConfig
module ErrorHandler = ErrorHandler
module DateUtils = DateUtils
module Etag = Etag

let listen ?(inetAddr = Unix.inet_addr_any) port serverConfig =
  let listenAddress = Unix.(ADDR_INET (inetAddr, port)) in
  let connectionHandler = Server.buildConnectionHandler serverConfig in

  Lwt.async (fun () ->
    let%lwt _server = Lwt_io.establish_server_with_client_socket
      listenAddress
      connectionHandler
    in
    ServerConfig.onListen serverConfig ();
    Lwt.return_unit
  );

  Lwt.wait ()

let listenAndWaitForever ?(inetAddr = Unix.inet_addr_any) port serverConfig =
  let (forever, _) = listen ~inetAddr port serverConfig in
  forever 