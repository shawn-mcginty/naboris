let test_suite () =
  ( "ServerConfig",
    [
      Alcotest_lwt.test_case "match_paths matches properly" `Quick
        (fun _lwt_switch _ ->
          let path_prefix = [ "static" ] in
          let path = [ "static"; "js"; "my_app.js" ] in
          let r_path = Naboris.ServerConfig.match_paths path_prefix path in
          let expected_rpath = Some [ "js"; "my_app.js" ] in

          let () =
            Alcotest.check
              (Alcotest.option (Alcotest.list Alcotest.string))
              "remaining path" expected_rpath r_path
          in

          Lwt.return_unit);
    ] )
