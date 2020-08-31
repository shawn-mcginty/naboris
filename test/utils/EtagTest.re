let testSuite = () => (
  "utils_Etag",
  [
    Alcotest_lwt.test_case(
      "fromString handles empty payload properly",
      `Quick,
      (_lwtSwitch, _) => {
        let payload = ""; // empty string response
				let emptyEtag = "\"0-2jmj7l5rSw0yVb/vlWAYkK/YBwk\"";
        Alcotest.(
          check(
            string,
            "empty payload etag",
            Naboris.Etag.fromString(payload),
            emptyEtag,
          )
        );
        Lwt.return_unit;
      },
    ),
		Alcotest_lwt.test_case(
      "fromString returns the same etag for the same entity",
      `Quick,
      (_lwtSwitch, _) => {
        let payload = "Some payload here there and around. And let's make it even longer with another line.";
				let expectedEtag = "\"84-rp6iUbxN39hxY6WTUx4KmuI2TTo\"";
        Alcotest.(
          check(
            string,
            "empty payload etag",
            Naboris.Etag.fromString(payload),
            expectedEtag,
          )
        );
        Lwt.return_unit;
      },
    ),
		Alcotest_lwt.test_case(
      "weakFromString handles empty payload properly",
      `Quick,
      (_lwtSwitch, _) => {
        let payload = ""; // empty string response
				let emptyEtag = "W/\"0-2jmj7l5rSw0yVb/vlWAYkK/YBwk\"";
        Alcotest.(
          check(
            string,
            "empty payload etag",
            Naboris.Etag.weakFromString(payload),
            emptyEtag,
          )
        );
        Lwt.return_unit;
      },
    ),
		Alcotest_lwt.test_case(
      "weakFromString returns the same etag for the same entity",
      `Quick,
      (_lwtSwitch, _) => {
        let payload = "Some payload here there and around. And let's make it even longer with another line.";
				let expectedEtag = "W/\"84-rp6iUbxN39hxY6WTUx4KmuI2TTo\"";
        Alcotest.(
          check(
            string,
            "empty payload etag",
            Naboris.Etag.weakFromString(payload),
            expectedEtag,
          )
        );
        Lwt.return_unit;
      },
    ),
  ]
);