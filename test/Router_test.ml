let test_suite () =
  ( "Router",
    [
      Alcotest_lwt.test_case "process_path errors on empty string" `Quick
        (fun _lwt_switch _ ->
          let _ = Naboris.Router.process_path "" in
          Lwt.return_unit);
    ] )
