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

let testServerConfig: Naboris.Server.serverConfig = {
  onListen: () => {
    print_string("🐫 Started a server on port 9991!\n\n");
    switch (startTests(MainTestSpec.tests)) {
    | TestDone => exit(0)
    | _ => exit(1)
    };
  },
  routes: [
    {
      method: GET,
      path: "/html",
      requestHandler: (req, res) => {
        Naboris.Res.status(200, res)
        |> Naboris.Res.html(
             req,
             "<!doctype html><html><body>You made it.</body></html>",
           );
      },
    },
    {
      method: GET,
      path: "/user/:userId/item/:itemId",
      requestHandler: (req, res) => {
        Naboris.Res.status(200, res)
        |> Naboris.Res.html(
             req,
             "<!doctype html><html><body>You want some user id and item</body></html>",
           );
      },
    },
    {
      method: GET,
      path: "/echo/:str",
      requestHandler: (req, res) => {
        let maybeStr =
          List.find_opt(
            x =>
              switch (x) {
              | ("str", _) => true
              | _ => false
              },
            req.params,
          );

        switch (maybeStr) {
        | Some((_, str)) =>
          Naboris.Res.status(200, res) |> Naboris.Res.html(req, str)
        | _ => Naboris.Res.status(500, res) |> Naboris.Res.html(req, "fail")
        };
      },
    },
    {
      method: GET,
      path: "/echo/:str1/multi/:str2",
      requestHandler: (req, res) => {
        let maybeStr1 =
          List.find_opt(
            x =>
              switch (x) {
              | ("str1", _) => true
              | _ => false
              },
            req.params,
          );
        let maybeStr2 =
          List.find_opt(
            x =>
              switch (x) {
              | ("str2", _) => true
              | _ => false
              },
            req.params,
          );

        let vals = [maybeStr1, maybeStr2];

        switch (vals) {
        | [Some((_x, str1)), Some((_y, str2))] =>
          Naboris.Res.status(200, res)
          |> Naboris.Res.html(req, str1 ++ "\n" ++ str2)
        | _ => Naboris.Res.status(500, res) |> Naboris.Res.html(req, "fail")
        };
      },
    },
  ],
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