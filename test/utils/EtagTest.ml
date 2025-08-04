let testSuite () =
  ("utils_Etag",
   [
     Alcotest_lwt.test_case
       "fromString handles empty payload properly"
       `Quick
       (fun _lwtSwitch _ ->
          let payload = "" in (* empty string response *)
          let emptyEtag = "\"0-2jmj7l5rSw0yVb/vlWAYkK/YBwk\"" in
          Alcotest.(
            check
              string
              "empty payload etag"
              (Naboris.Etag.fromString payload)
              emptyEtag
          );
          Lwt.return_unit);
     Alcotest_lwt.test_case
       "fromString returns the same etag for the same entity"
       `Quick
       (fun _lwtSwitch _ ->
          let payload = "Some payload here there and around. And let's make it even longer with another line." in
          let expectedEtag = "\"84-rp6iUbxN39hxY6WTUx4KmuI2TTo\"" in
          Alcotest.(
            check
              string
              "empty payload etag"
              (Naboris.Etag.fromString payload)
              expectedEtag
          );
          Lwt.return_unit);
     Alcotest_lwt.test_case
       "weakFromString handles empty payload properly"
       `Quick
       (fun _lwtSwitch _ ->
          let payload = "" in (* empty string response *)
          let emptyEtag = "W/\"0-2jmj7l5rSw0yVb/vlWAYkK/YBwk\"" in
          Alcotest.(
            check
              string
              "empty payload etag"
              (Naboris.Etag.weakFromString payload)
              emptyEtag
          );
          Lwt.return_unit);
     Alcotest_lwt.test_case
       "weakFromString returns the same etag for the same entity"
       `Quick
       (fun _lwtSwitch _ ->
          let payload = "Some payload here there and around. And let's make it even longer with another line." in
          let expectedEtag = "W/\"84-rp6iUbxN39hxY6WTUx4KmuI2TTo\"" in
          Alcotest.(
            check
              string
              "empty payload etag"
              (Naboris.Etag.weakFromString payload)
              expectedEtag
          );
          Lwt.return_unit);
   ]) 