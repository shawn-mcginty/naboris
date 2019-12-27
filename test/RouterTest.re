let testSuite = () => (
  "Router",
  [
    Alcotest.test_case(
      "processPath errors on empty string",
      `Quick,
      _ => {
        let _ = Naboris.Router.processPath("");
        ();
      },
    ),
  ],
);