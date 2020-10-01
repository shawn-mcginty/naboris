open Naboris

let main () =
  let nab_conf =
    ServerConfig.make ()
    |> ServerConfig.set_on_listen (fun () ->
           print_endline "Server started at 9997")
    |> ServerConfig.set_request_handler (fun route req res ->
           match Route.path route with
           | "static" :: path ->
               let public_dir = Sys.getcwd () ^ "/load-test/public/" in
               Naboris.Res.static public_dir path req res
           | _ -> res |> Res.status 404 |> Res.text req "Not Found")
  in
  listen_and_wait_forever 9997 nab_conf

let () = Lwt_engine.set (new Lwt_engine.libev ())

let _ = Lwt_main.run (main ())
