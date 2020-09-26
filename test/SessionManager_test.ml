let default_secret = "keep it secret, keep it safe"

let test_suite () =
  ( "SessionManager",
    [
      Alcotest_lwt.test_case
        "generate_session_id - returns unique 32 char long string" `Quick
        (fun _lwt_switch _ ->
          let id1 = Naboris.SessionManager.generate_session_id () in
          let id2 = Naboris.SessionManager.generate_session_id () in
          let () =
            Alcotest.(check bool "id sshould not match" false (id1 = id2))
          in
          let () =
            Alcotest.(
              check int "should be 32 chars long" 32 (String.length id1))
          in
          let () =
            Alcotest.(
              check int "should be 32 chars long" 32 (String.length id2))
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case "sign - returns {sid}.{hash}" `Quick
        (fun _lwt_switch _ ->
          let secret = default_secret in
          (* default secret *)
          let sid = Naboris.SessionManager.generate_session_id () in
          let signed_sid = Naboris.SessionManager.sign secret sid in
          let more_sid, hash =
            match String.split_on_char '.' signed_sid with
            | [ x; y ] -> (x, y)
            | _ -> ("", "")
          in
          let () = Alcotest.(check string "sids should match" sid more_sid) in
          let () =
            Alcotest.(check bool "sid should not match hash" false (sid = hash))
          in
          let () =
            Alcotest.(
              check bool "sid should not match signed_sid" false
                (sid = signed_sid))
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "unsign - takes sid.hash returns sid if hashed properly" `Quick
        (fun _lwt_switch _ ->
          let secret = default_secret in
          let sid = Naboris.SessionManager.generate_session_id () in
          let signed_sid = Naboris.SessionManager.sign secret sid in
          let unsigned_sid = Naboris.SessionManager.unsign secret signed_sid in
          let () =
            Alcotest.(
              check (option string) "sids should match" (Some sid) unsigned_sid)
          in
          Lwt.return_unit);
    ] )
