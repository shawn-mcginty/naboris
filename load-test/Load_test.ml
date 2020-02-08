open Naboris

let main ()=
  let nab_conf = ServerConfig.create ()
    |> ServerConfig.setOnListen(fun () -> print_endline("Server started at 9997"))
    |> ServerConfig.setRequestHandler(fun route req res -> match (Route.path route) with
      | "static" :: path ->
        let public_dir = Sys.getcwd () ^ "/load-test/public/" in
        Naboris.Res.static public_dir path req res
      | _ -> res |> Res.status 404 |> Res.text req "Not Found") in
  listenAndWaitForever 9997 nab_conf

let () = Lwt_engine.set (new Lwt_engine.libev ())
let _ = Lwt_main.run(main ())