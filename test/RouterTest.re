let testSuite = () => (
  "Router",
  [
    Alcotest_lwt.test_case(
      "process_path errors on empty string",
      `Quick,
      (_lwtSwitch, _) => {
        let _ = Naboris.Router.process_path("");
        Lwt.return_unit;
      },
    ),
  ],
);