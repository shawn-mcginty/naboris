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

let listen ?(inet_addr = Unix.inet_addr_any) port
    (server_config : 'sessionData ServerConfig.t) =
  let listen_address = Unix.ADDR_INET (inet_addr, port) in
  let connection_handler = Server.build_connection_handler server_config in

  let _ =
    Lwt.async (fun () ->
        let%lwt _server =
          Lwt_io.establish_server_with_client_socket listen_address
            connection_handler
        in
        let () = ServerConfig.on_listen server_config () in
        Lwt.return_unit)
  in

  Lwt.wait ()

let listen_and_wait_forever ?(inet_addr = Unix.inet_addr_any) port
    (server_config : 'sessionData ServerConfig.t) =
  let forever, _ = listen ~inet_addr port server_config in
  forever
