let testSuite () =
  ("Method",
   [
     Alcotest_lwt.test_case
       "ofString returns good values for all good strings"
       `Quick
       (fun _lwtSwitch _ ->
          Alcotest.(
            check bool "GET" true (Naboris.Method.ofString "GET" = GET)
          );
          Alcotest.(
            check bool "POST" true (Naboris.Method.ofString "POST" = POST)
          );
          Alcotest.(
            check bool "PUT" true (Naboris.Method.ofString "PUT" = PUT)
          );
          Alcotest.(
            check
              bool
              "PATCH"
              true
              (Naboris.Method.ofString "PATCH" = PATCH)
          );
          Alcotest.(
            check
              bool
              "DELETE"
              true
              (Naboris.Method.ofString "DELETE" = DELETE)
          );
          Alcotest.(
            check
              bool
              "CONNECT"
              true
              (Naboris.Method.ofString "CONNECT" = CONNECT)
          );
          Alcotest.(
            check
              bool
              "OPTIONS"
              true
              (Naboris.Method.ofString "OPTIONS" = OPTIONS)
          );
          Alcotest.(
            check
              bool
              "TRACE"
              true
              (Naboris.Method.ofString "TRACE" = TRACE)
          );
          Lwt.return_unit);
     Alcotest_lwt.test_case
       "ofString returns Other(s) when given s non standard value"
       `Quick
       (fun _lwtSwitch _ ->
          Alcotest.(
            check
              bool
              "foo"
              true
              (Naboris.Method.ofString "foo" = Other "foo")
          );
          Alcotest.(
            check
              bool
              "bar"
              true
              (Naboris.Method.ofString "bar" = Other "bar")
          );
          Lwt.return_unit);
     Alcotest_lwt.test_case
       "toString converts all standard meths to string values"
       `Quick
       (fun _lwtSwitch _ ->
          Alcotest.(check string "GET" (Naboris.Method.toString GET) "GET");
          Alcotest.(
            check string "POST" (Naboris.Method.toString POST) "POST"
          );
          Alcotest.(check string "PUT" (Naboris.Method.toString PUT) "PUT");
          Alcotest.(
            check string "PATCH" (Naboris.Method.toString PATCH) "PATCH"
          );
          Alcotest.(
            check string "DELETE" (Naboris.Method.toString DELETE) "DELETE"
          );
          Alcotest.(
            check
              string
              "CONNECT"
              (Naboris.Method.toString CONNECT)
              "CONNECT"
          );
          Alcotest.(
            check
              string
              "OPTIONS"
              (Naboris.Method.toString OPTIONS)
              "OPTIONS"
          );
          Alcotest.(
            check string "TRACE" (Naboris.Method.toString TRACE) "TRACE"
          );
          Lwt.return_unit);
     Alcotest_lwt.test_case
       "toString converts non standard to string"
       `Quick
       (fun _lwtSwitch _ ->
          Alcotest.(
            check string "foo" (Naboris.Method.toString (Other "foo")) "foo"
          );
          Alcotest.(
            check string "bar" (Naboris.Method.toString (Other "bar")) "bar"
          );
          Lwt.return_unit);
   ]) 