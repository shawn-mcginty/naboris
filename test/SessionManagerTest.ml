let testSuite () =
  ("SessionManager",
   [
     Alcotest_lwt.test_case
       "generateSessionId() - returns unique 32 char long stringsz"
       `Quick
       (fun _lwtSwitch _ ->
          let id1 = Naboris.SessionManager.generateSessionId () in
          let id2 = Naboris.SessionManager.generateSessionId () in
          Alcotest.(
            check bool "ids should not match" false (id1 = id2)
          );
          Alcotest.(
            check int "should be 32 chars" 32 (String.length id1)
          );
          Alcotest.(
            check int "should be 32 chars" 32 (String.length id2)
          );
          
          Lwt.return_unit);
     Alcotest_lwt.test_case
       "sign() - returns sid dot separated by a hash"
       `Quick
       (fun _lwtSwitch _ ->
          let secret = "keep it secret, keep it safe" in
          let sid = Naboris.SessionManager.generateSessionId () in
          let signedSid = Naboris.SessionManager.sign secret sid in
          let (moreSid, hash) = 
            match String.split_on_char '.' signedSid with
            | [x; y] -> (x, y)
            | _ -> ("", "")
          in
          Alcotest.(
            check bool "sids should match" true (sid = moreSid)
          );
          Alcotest.(
            check bool "ids should not match" false (sid = hash)
          );
          Alcotest.(
            check bool "ids should not match" false (sid = signedSid)
          );
          Lwt.return_unit);
     Alcotest_lwt.test_case
       "unsign() - takes sid.hash returns sid if hashed properly"
       `Quick
       (fun _lwtSwitch _ ->
          let secret = "keep it secret, keep it safe" in
          let sid = Naboris.SessionManager.generateSessionId () in
          let signedSid = Naboris.SessionManager.sign secret sid in
          let unsignedSid = Naboris.SessionManager.unsign secret signedSid in
          Alcotest.(
            check (option string) "sids should match" (Some sid) unsignedSid
          );
          Lwt.return_unit);
   ]) 