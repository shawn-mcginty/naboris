open OUnit;

let suite =
  "NaborisTest"
  >::: List.concat([MimeTypesTest.testSuite(), CookieTest.testSuite()]);

run_test_tt_main(suite);
();