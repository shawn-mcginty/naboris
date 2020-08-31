let runTests = () => {
  if (Sys.getenv_opt("NABORIS_LIBEV_TEST") == Some("true")) {
    Lwt_engine.set(new Lwt_engine.libev());
    print_endline("Set lwt engine to libev explicitly.");
  } else {
    print_endline("DIT NOT set lwt engine to libev explicitly.");
  }

  Lwt_main.run @@ Alcotest_lwt.run(
    "Naboris_Tests",
    [
      CookieTest.testSuite(),
      DateUtilsTest.testSuite(),
      MimeTypesTest.testSuite(),
      EtagTest.testSuite(),
      MethodTest.testSuite(),
      RouterTest.testSuite(),
      SessionManagerTest.testSuite(),
      IntegrationTest.testSuite(),
    ]
  );
};

runTests();