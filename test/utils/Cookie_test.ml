let test_suite () =
  ( "utils_Cookie",
    [
      Alcotest_lwt.test_case
        "get_session_id returns the id from the ugly string" `Quick
        (fun _lwt_switch _ ->
          let expected_sid = "this-is-my-big-ass-session-id-woohoo" in
          let cookie_str =
            "this=ugly; super=ugly; nab.sid=" ^ expected_sid ^ "; also=here;"
          in
          let () =
            Alcotest.(
              check (option string) "same sid"
                (Naboris.Cookie.get_session_id "nab.sid" cookie_str)
                (Some expected_sid))
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case "get_session_id fix recursion bug" `Quick
        (fun _lwt_switch _ ->
          let cookie_str =
            "nnect.sid=s%3AadVKe5fVEcZVq4X5ZUrMen2U88jmjy4f.LOwere3akcgCno7WDqinHgL%2BXWXVp2SgbHZzv7%2Btbt4"
          in
          let maybe_cookie =
            Naboris.Cookie.get_session_id "nab.sid" cookie_str
          in
          let () =
            Alcotest.(
              check (option string) "no matching cookie" None maybe_cookie)
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case "get_session_id fix big cookie str" `Quick
        (fun _lwt_switch _ ->
          let expected_sid =
            "67f67df4c5d9711ef89bbf8b509d49e2cc1ce51e3d95c90d45485a7b3cf40ca4ec9cbbceb0ca6ad844ec4a4779fd9981b130c40f81646f2ef286749c7184e66f"
          in
          let cookie_str =
            "_ga=GA1.1.1652070095.1563853850; \
             express.sid=s%3AhSEgvCCmOADa-0Flv4ulT1FltA8TzHeq.G1UoU2xXC8X8wkEO5I0J%2BhE3NCjUoggAlGnz0jA1%2B2w; \
             _gid=GA1.1.1409339010.1564626384; \
             connect.sid=s%3AClROuVLX_Dalzkmf0D4d0Xath-HHG16M.8zaxTWykLFnypEw%2BCAIZRTPJR7IKBDUcAamWUch4Czk; \
             nab.sid=67f67df4c5d9711ef89bbf8b509d49e2cc1ce51e3d95c90d45485a7b3cf40ca4ec9cbbceb0ca6ad844ec4a4779fd9981b130c40f81646f2ef286749c7184e66f"
          in
          let maybe_sid = Naboris.Cookie.get_session_id "nab.sid" cookie_str in
          let () =
            Alcotest.(
              check (option string) "same sid" maybe_sid (Some expected_sid))
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "get_session_id returns none when cookie str is part of the key" `Quick
        (fun _lwt_switch _ ->
          let cookie_str = "nib" in
          let () =
            Alcotest.(
              check (option string) "empty"
                (Naboris.Cookie.get_session_id "nab.sid" cookie_str)
                None)
          in
          Lwt.return_unit);
    ] )
