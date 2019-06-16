open Lwt.Infix;

exception Timeout;
exception TestFailed;

let timeout = time =>
  Lwt_unix.sleep(time) >>= (() => Lwt.return((TestResult.TestTimeout, time)));
let mainTimeout = timeout(60.0);
let perTestTimeout = () => timeout(5.0);

let timeoutTest = title => {
  print_string(" ❌ " ++ title ++ " has timed out\n");
};

let reportFailed = (title, (msg, _line, _col)) =>
  print_string(" ❌ " ++ title ++ " " ++ msg ++ "\n");

let rec startTests = (~total=0, ~success=0, ~failed=0, tests) => {
  switch (tests) {
  | [] =>
    print_string(
      "\n\nDone! "
      ++ string_of_int(success)
      ++ " passing    "
      ++ string_of_int(failed)
      ++ " failing.\n\n",
    );
    if (failed > 0) {
      TestResult.SomeFailures;
    } else {
      TestResult.TestDone;
    };
  | [h, ...rest] => runTest(h, rest, total, success, failed)
  };
}
and runTest = (test: Spec.t, rest, t, s, f) => {
  switch (Lwt.pick([perTestTimeout(), test.test()]) |> Lwt_main.run) {
  | (TestResult.TestTimeout, _time) =>
    timeoutTest(test.title);
    startTests(rest, ~total=t + 1, ~success=s, ~failed=f + 1);
  | exception (Assert_failure(err)) =>
    reportFailed(test.title, err);
    startTests(rest, ~total=t + 1, ~success=s, ~failed=f + 1);
  | _ =>
    print_string(" ✅ " ++ test.title ++ "\n");
    startTests(rest, ~total=t + 1, ~success=s + 1, ~failed=f);
  };
};

let echoQueryQuery = (req, res, query) => {
  let maybeStr1 = Naboris.QueryMap.find_opt("q", query);
  let maybeStr2 = Naboris.QueryMap.find_opt("q2", query);
  let maybeStr3 = Naboris.QueryMap.find_opt("q3", query);

  let vals = [maybeStr1, maybeStr2, maybeStr3];

  switch (vals) {
  | [Some([str1, ..._]), Some([str2, ..._]), Some([str3, ..._])] =>
    Naboris.Res.status(200, res)
    |> Naboris.Res.html(req, str1 ++ "\n" ++ str2 ++ "\n" ++ str3)
  | _ => Naboris.Res.status(500, res) |> Naboris.Res.html(req, "fail")
  };
};

let testServerConfig: Naboris.Server.serverConfig(unit) = {
  onListen: () => {
    print_string("🐫 Started a server on port 9991!\n\n");
    switch (startTests(MainTestSpec.tests)) {
    | TestDone => exit(0)
    | _ => exit(1)
    };
  },
  sessionConfig: None,
  routeRequest: (route, req, res) =>
    switch (route.method, route.path) {
    | (Naboris.Method.GET, ["echo", "pre-existing-route"]) =>
      Naboris.Res.status(200, res)
      |> Naboris.Res.html(
           req,
           "This route should take priority in the matcher.",
         );
      Lwt.return_unit;
    | (Naboris.Method.GET, ["html"]) =>
      Naboris.Res.status(200, res)
      |> Naboris.Res.html(
           req,
           "<!doctype html><html><body>You made it.</body></html>",
         );
      Lwt.return_unit;
    | (Naboris.Method.GET, ["user", _userId, "item", _itemId]) =>
      Naboris.Res.status(200, res)
      |> Naboris.Res.html(
           req,
           "<!doctype html><html><body>You want some user id and item</body></html>",
         );
      Lwt.return_unit;
    | (Naboris.Method.GET, ["echo-query", "query"]) =>
      echoQueryQuery(req, res, route.query);
      Lwt.return_unit;
    | (Naboris.Method.GET, ["echo", str]) =>
      Naboris.Res.status(200, res) |> Naboris.Res.html(req, str);
      Lwt.return_unit;
    | (Naboris.Method.GET, ["echo", str1, "multi", str2]) =>
      Naboris.Res.status(200, res)
      |> Naboris.Res.html(req, str1 ++ "\n" ++ str2);
      Lwt.return_unit;
    | (POST, ["echo"]) =>
      Lwt.bind(
        Naboris.Req.getBody(req),
        bodyStr => {
          Naboris.Res.status(200, res) |> Naboris.Res.html(req, bodyStr);
          Lwt.return_unit;
        },
      )
    | (GET, ["static", ...staticPath]) =>
      Naboris.Res.static(
        Sys.getcwd() ++ "/integration-test/test_assets",
        staticPath,
        req,
        res,
      )
    | _ =>
      Naboris.Res.status(404, res)
      |> Naboris.Res.html(
           req,
           "<!doctype html><html><body>Page not found</body></html>",
         );
      Lwt.return_unit;
    },
};

let serverRunning = Naboris.listen(9991, testServerConfig);

let run = () => {
  switch (Lwt.pick([mainTimeout, serverRunning]) |> Lwt_main.run) {
  | (TestResult.TestTimeout, _time) =>
    print_string("🚫 Timed out!\n\n");
    exit(1);
  | _ => exit(0)
  };
};

run();