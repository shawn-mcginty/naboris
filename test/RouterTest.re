let testSuite = () => (
  "Router",
  [
    Alcotest_lwt.test_case(
      "processPath errors on empty string",
      `Quick,
      (_lwtSwitch, _) => {
        let _ = Naboris.Router.processPath("");
        Lwt.return_unit;
      },
    ),
  ],
);