let test_suite () =
  ( "Method",
    [
      Alcotest_lwt.test_case
        "of_string returns good values for all good strings" `Quick
        (fun _lwt_switch _ ->
          let () =
            Alcotest.(
              check bool "GET" true (Naboris.Method.of_string "GET" == GET))
          in
          let () =
            Alcotest.(
              check bool "POST" true (Naboris.Method.of_string "POST" == POST))
          in
          let () =
            Alcotest.(
              check bool "PUT" true (Naboris.Method.of_string "PUT" == PUT))
          in
          let () =
            Alcotest.(
              check bool "PATCH" true (Naboris.Method.of_string "PATCH" == PATCH))
          in
          let () =
            Alcotest.(
              check bool "DELETE" true
                (Naboris.Method.of_string "DELETE" == DELETE))
          in
          let () =
            Alcotest.(
              check bool "CONNECT" true
                (Naboris.Method.of_string "CONNECT" == CONNECT))
          in
          let () =
            Alcotest.(
              check bool "OPTIONS" true
                (Naboris.Method.of_string "OPTIONS" == OPTIONS))
          in
          let () =
            Alcotest.(
              check bool "TRACE" true (Naboris.Method.of_string "TRACE" == TRACE))
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "of_string returns Other(s) when given a non standard value" `Quick
        (fun _lwt_switch _ ->
          let () =
            Alcotest.(
              check bool "foo" true
                (Naboris.Method.of_string "foo" = Other "foo"))
          in
          let () =
            Alcotest.(
              check bool "bar" true
                (Naboris.Method.of_string "bar" = Other "bar"))
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "to_string converts all standard meths to string value" `Quick
        (fun _lwt_switch _ ->
          let () =
            Alcotest.(check string "GET" (Naboris.Method.to_string GET) "GET")
          in
          let () =
            Alcotest.(
              check string "POST" (Naboris.Method.to_string POST) "POST")
          in
          let () =
            Alcotest.(check string "PUT" (Naboris.Method.to_string PUT) "PUT")
          in
          let () =
            Alcotest.(
              check string "PATCH" (Naboris.Method.to_string PATCH) "PATCH")
          in
          let () =
            Alcotest.(
              check string "DELETE" (Naboris.Method.to_string DELETE) "DELETE")
          in
          let () =
            Alcotest.(
              check string "CONNECT"
                (Naboris.Method.to_string CONNECT)
                "CONNECT")
          in
          let () =
            Alcotest.(
              check string "OPTIONS"
                (Naboris.Method.to_string OPTIONS)
                "OPTIONS")
          in
          let () =
            Alcotest.(
              check string "TRACE" (Naboris.Method.to_string TRACE) "TRACE")
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case "to_string converts non standard to string" `Quick
        (fun _lwt_switch _ ->
          let () =
            Alcotest.(
              check string "foo" (Naboris.Method.to_string (Other "foo")) "foo")
          in
          let () =
            Alcotest.(
              check string "foo" (Naboris.Method.to_string (Other "bar")) "bar")
          in
          Lwt.return_unit);
    ] )
