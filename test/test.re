let runTests = () => {
  if (Sys.getenv_opt("NABORIS_LIBEV_TEST") == Some("true")) {
    Lwt_engine.set(new Lwt_engine.libev());
    print_endline("Set lwt engine to libev explicitly.");
  } else {
    print_endline("DIT NOT set lwt engine to libev explicitly.");
  }
  Alcotest.run(
    "Naboris Test",
    [
      CookieTest.testSuite(),
      MimeTypesTest.testSuite(),
      MethodTest.testSuite(),
      RouterTest.testSuite(),
      IntegrationTest.testSuite(),
    ],
  );
};

runTests();