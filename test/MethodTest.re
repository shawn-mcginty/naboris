let testSuite = () => (
  "Method",
  [
    Alcotest_lwt.test_case(
      "ofString returns good values for all good strings",
      `Quick,
      (_lwtSwitch, _) => {
        Alcotest.(
          check(bool, "GET", true, Naboris.Method.of_string("GET") == GET)
        );
        Alcotest.(
          check(bool, "POST", true, Naboris.Method.of_string("POST") == POST)
        );
        Alcotest.(
          check(bool, "PUT", true, Naboris.Method.of_string("PUT") == PUT)
        );
        Alcotest.(
          check(
            bool,
            "PATCH",
            true,
            Naboris.Method.of_string("PATCH") == PATCH,
          )
        );
        Alcotest.(
          check(
            bool,
            "DELETE",
            true,
            Naboris.Method.of_string("DELETE") == DELETE,
          )
        );
        Alcotest.(
          check(
            bool,
            "CONNECT",
            true,
            Naboris.Method.of_string("CONNECT") == CONNECT,
          )
        );
        Alcotest.(
          check(
            bool,
            "OPTIONS",
            true,
            Naboris.Method.of_string("OPTIONS") == OPTIONS,
          )
        );
        Alcotest.(
          check(
            bool,
            "TRACE",
            true,
            Naboris.Method.of_string("TRACE") == TRACE,
          )
        );
        Lwt.return_unit;
      },
    ),
    Alcotest_lwt.test_case(
      "ofString returns Other(s) when given s non standard value",
      `Quick,
      (_lwtSwitch, _) => {
        Alcotest.(
          check(
            bool,
            "foo",
            true,
            Naboris.Method.of_string("foo") == Other("foo"),
          )
        );
        Alcotest.(
          check(
            bool,
            "bar",
            true,
            Naboris.Method.of_string("bar") == Other("bar"),
          )
        );
        Lwt.return_unit;
      },
    ),
    Alcotest_lwt.test_case(
      "toString converts all standard meths to string values",
      `Quick,
      (_lwtSwitch, _) => {
        Alcotest.(check(string, "GET", Naboris.Method.to_string(GET), "GET"));
        Alcotest.(
          check(string, "POST", Naboris.Method.to_string(POST), "POST")
        );
        Alcotest.(check(string, "PUT", Naboris.Method.to_string(PUT), "PUT"));
        Alcotest.(
          check(string, "PATCH", Naboris.Method.to_string(PATCH), "PATCH")
        );
        Alcotest.(
          check(string, "DELETE", Naboris.Method.to_string(DELETE), "DELETE")
        );
        Alcotest.(
          check(
            string,
            "CONNECT",
            Naboris.Method.to_string(CONNECT),
            "CONNECT",
          )
        );
        Alcotest.(
          check(
            string,
            "OPTIONS",
            Naboris.Method.to_string(OPTIONS),
            "OPTIONS",
          )
        );
        Alcotest.(
          check(string, "TRACE", Naboris.Method.to_string(TRACE), "TRACE")
        );
        Lwt.return_unit;
      },
    ),
    Alcotest_lwt.test_case(
      "toString converts non standard to string",
      `Quick,
      (_lwtSwitch, _) => {
        Alcotest.(
          check(string, "foo", Naboris.Method.to_string(Other("foo")), "foo")
        );
        Alcotest.(
          check(string, "bar", Naboris.Method.to_string(Other("bar")), "bar")
        );
        Lwt.return_unit;
      },
    ),
  ],
);