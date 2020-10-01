let test_suite () =
  ( "utils_Etag",
    [
      Alcotest_lwt.test_case "of_string handles empty payload properly" `Quick
        (fun _lwt_switch _ ->
          let payload = "" in
          (* empty string response *)
          let empty_etag = "\"0-2jmj7l5rSw0yVb/vlWAYkK/YBwk\"" in
          let () =
            Alcotest.(
              check string "empty payload etag"
                (Naboris.Etag.of_string payload)
                empty_etag)
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "of_string returns the same etag for the same entity" `Quick
        (fun _lwt_switch _ ->
          let payload =
            "Some payload here there and around. And let's make it even longer \
             with another line."
          in
          let expected_etag = "\"84-rp6iUbxN39hxY6WTUx4KmuI2TTo\"" in
          let () =
            Alcotest.(
              check string "empty payload etag"
                (Naboris.Etag.of_string payload)
                expected_etag)
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case "weak_of_string handles empty payload properly"
        `Quick (fun _lwt_switch _ ->
          let payload = "" in
          (* empty string response *)
          let empty_etag = "W/\"0-2jmj7l5rSw0yVb/vlWAYkK/YBwk\"" in
          let () =
            Alcotest.(
              check string "empty payload etag"
                (Naboris.Etag.weak_of_string payload)
                empty_etag)
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "weak_of_string returns the same etag for the same entity" `Quick
        (fun _lwt_switch _ ->
          let payload =
            "Some payload here there and around. And let's make it even longer \
             with another line."
          in
          let expected_etag = "W/\"84-rp6iUbxN39hxY6WTUx4KmuI2TTo\"" in
          let () =
            Alcotest.(
              check string "empty payload etag"
                (Naboris.Etag.weak_of_string payload)
                expected_etag)
          in
          Lwt.return_unit);
    ] )
