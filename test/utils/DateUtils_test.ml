let test_suite () =
  ( "utils_DateUtils",
    [
      Alcotest_lwt.test_case
        "format_for_headers takes a float and formats it properly" `Quick
        (fun _lwt_switch _ ->
          (* 7/26/2020 7:36pm GMT *)
          let time = 1595792156.0 in
          let formatted_time = Naboris.DateUtils.format_for_headers time in
          let () =
            Alcotest.(
              check string "formatted time" formatted_time
                "Sun, 26 Jul 2020 19:35:56 GMT")
          in
          Lwt.return_unit);
    ] )
