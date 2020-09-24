let testSuite = () => (
  "utils_DateUtils",
  [
    Alcotest_lwt.test_case(
      "format_for_headers taks a float and formats it properly",
      `Quick,
      (_lwtSwitch, _) => {
        // 7/26/2020 7:36pm GMT
        let time = 1595792156.0;
        let formattedTime = Naboris.DateUtils.format_for_headers(time);
        Alcotest.(
          check(
            string,
            "formatted time",
            formattedTime,
            "Sun, 26 Jul 2020 19:35:56 GMT",
          )
        );
        Lwt.return_unit;
      },
    ),
  ],
);
