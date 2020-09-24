let testSuite = () => (
  "SessionManager",
  [
    Alcotest_lwt.test_case(
      "generateSessionId() - returns unique 32 char long stringsz",
      `Quick,
      (_lwtSwitch, _) => {
        let id1 = Naboris.SessionManager.generate_session_id();
        let id2 = Naboris.SessionManager.generate_session_id();
        Alcotest.(
          check(bool, "ids should not match", false, id1 == id2)
        );
        Alcotest.(
          check(int, "should be 32 chars", 32, String.length(id1))
        );
        Alcotest.(
          check(int, "should be 32 chars", 32, String.length(id2))
        );
        
        Lwt.return_unit;
      },
    ),
    Alcotest_lwt.test_case(
      "sign() - returns sid dot separated by a hash",
      `Quick,
      (_lwtSwitch, _) => {
        let secret = "keep it secret, keep it safe";
        let sid = Naboris.SessionManager.generate_session_id();
        let signedSid = Naboris.SessionManager.sign(secret, sid);
        let (moreSid, hash) = switch(String.split_on_char('.', signedSid)) {
          | [x, y] => (x, y)
          | _ => ("", "")
        };
        Alcotest.(
          check(bool, "sids should match", true, sid == moreSid)
        );
        Alcotest.(
          check(bool, "ids should not match", false, sid == hash)
        );
        Alcotest.(
          check(bool, "ids should not match", false, sid == signedSid)
        );
        Lwt.return_unit;
      },
    ),
    Alcotest_lwt.test_case(
      "unsign() - takes sid.hash returns sid if hashed properly",
      `Quick,
      (_lwtSwitch, _) => {
        let secret = "keep it secret, keep it safe";
        let sid = Naboris.SessionManager.generate_session_id();
        let signedSid = Naboris.SessionManager.sign(secret, sid);
        let unsignedSid = Naboris.SessionManager.unsign(secret, signedSid);
        Alcotest.(
          check(option(string), "sids should match", Some(sid), unsignedSid)
        );
        Lwt.return_unit;
      },
    ),
  ],
);