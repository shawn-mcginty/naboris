let testSuite = () => (
  "utils_Etag",
  [
    Alcotest_lwt.test_case(
      "of_string handles empty payload properly",
      `Quick,
      (_lwtSwitch, _) => {
        let payload = ""; // empty string response
				let emptyEtag = "\"0-2jmj7l5rSw0yVb/vlWAYkK/YBwk\"";
        Alcotest.(
          check(
            string,
            "empty payload etag",
            Naboris.Etag.of_string(payload),
            emptyEtag,
          )
        );
        Lwt.return_unit;
      },
    ),
		Alcotest_lwt.test_case(
      "of_string returns the same etag for the same entity",
      `Quick,
      (_lwtSwitch, _) => {
        let payload = "Some payload here there and around. And let's make it even longer with another line.";
				let expectedEtag = "\"84-rp6iUbxN39hxY6WTUx4KmuI2TTo\"";
        Alcotest.(
          check(
            string,
            "empty payload etag",
            Naboris.Etag.of_string(payload),
            expectedEtag,
          )
        );
        Lwt.return_unit;
      },
    ),
		Alcotest_lwt.test_case(
      "weak_of_string handles empty payload properly",
      `Quick,
      (_lwtSwitch, _) => {
        let payload = ""; // empty string response
				let emptyEtag = "W/\"0-2jmj7l5rSw0yVb/vlWAYkK/YBwk\"";
        Alcotest.(
          check(
            string,
            "empty payload etag",
            Naboris.Etag.weak_of_string(payload),
            emptyEtag,
          )
        );
        Lwt.return_unit;
      },
    ),
		Alcotest_lwt.test_case(
      "weak_of_string returns the same etag for the same entity",
      `Quick,
      (_lwtSwitch, _) => {
        let payload = "Some payload here there and around. And let's make it even longer with another line.";
				let expectedEtag = "W/\"84-rp6iUbxN39hxY6WTUx4KmuI2TTo\"";
        Alcotest.(
          check(
            string,
            "empty payload etag",
            Naboris.Etag.weak_of_string(payload),
            expectedEtag,
          )
        );
        Lwt.return_unit;
      },
    ),
  ]
);