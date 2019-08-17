let runTests = () => {
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