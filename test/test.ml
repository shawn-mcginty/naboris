let () =
  let () =
    match Sys.getenv_opt "NABORIS_LIBEV_TEST" with
    | Some "true" ->
        let _ = Lwt_engine.set (new Lwt_engine.libev ()) in
        print_endline "Saw lwt engine to libev explicitly."
    | _ -> print_endline "DID NOT set lwt engine to libev explicitly."
  in

  let _ =
    Alcotest_lwt.run "Naboris_Tests"
      [
        Cookie_test.test_suite ();
        DateUtils_test.test_suite ();
        MimeTypes_test.test_suite ();
        Etag_test.test_suite ();
        Method_test.test_suite ();
        Router_test.test_suite ();
        SessionManager_test.test_suite ();
        ServerConfig_test.test_suite ();
        IntegrationTest.testSuite ();
      ]
    |> Lwt_main.run
  in
  ()
