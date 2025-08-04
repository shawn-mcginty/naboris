let testSuite () =
  ("Router",
   [
     Alcotest_lwt.test_case
       "processPath errors on empty string"
       `Quick
       (fun _lwtSwitch _ ->
          let _ = Naboris.Router.processPath "" in
          Lwt.return_unit);
   ]) 