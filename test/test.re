open OUnit;

let suite = "NaborisTest" >::: MimeTypesTest.testSuite();

run_test_tt_main(suite);
();