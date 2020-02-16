open Lwt.Infix;

exception SomebodyGoofed(string);

let echoQueryQuery = (req, res, query) => {
  let maybeStr1 = Naboris.Query.QueryMap.find_opt("q", query);
  let maybeStr2 = Naboris.Query.QueryMap.find_opt("q2", query);
  let maybeStr3 = Naboris.Query.QueryMap.find_opt("q3", query);

  let vals = [maybeStr1, maybeStr2, maybeStr3];

  switch (vals) {
  | [Some([str1, ..._]), Some([str2, ..._]), Some([str3, ..._])] =>
    Naboris.Res.status(200, res)
    |> Naboris.Res.html(req, str1 ++ "\n" ++ str2 ++ "\n" ++ str3)
  | _ => Naboris.Res.status(500, res) |> Naboris.Res.html(req, "fail")
  };
};

let sessionConfig: Naboris.SessionConfig.t(TestSession.t) = {
  sidKey: "nab.sid",
  maxAge: 3600,
  getSession: sessionId => {
    let userData = TestSession.{username: "realsessionuser"};
    switch (sessionId) {
    | Some(sid) =>
      Lwt.return(Some(Naboris.Session.create(sid, userData)));
    | _ => Lwt.return(None)
    };
  },
};

let startServers = lwtSwitch => {
  let (ssp1, ssr1) = Lwt.task();
  let (ssp2, ssr2) = Lwt.task();
  let (ssp3, ssr3) = Lwt.task();

  Lwt_switch.add_hook(
    Some(lwtSwitch),
    () => {
      Lwt.cancel(ssp1);
      Lwt.cancel(ssp2);
      Lwt.return_unit;
    },
  );

  let testServerConfig: Naboris.ServerConfig.t(TestSession.t) = Naboris.ServerConfig.create()
    |> Naboris.ServerConfig.setOnListen(() => Lwt.wakeup_later(ssr1, ()))
    |> Naboris.ServerConfig.setSessionConfig(sessionConfig.getSession)
    |> Naboris.ServerConfig.addStaticMiddleware(["static"], Sys.getenv("cur__root") ++ "/test/integration-test/test_assets")
    |> Naboris.ServerConfig.setRequestHandler((route, req, res) =>
      switch (Naboris.Route.meth(route), Naboris.Route.path(route)) {
      | (Naboris.Method.GET, ["echo", "pre-existing-route"]) =>
        Naboris.Res.status(200, res)
        |> Naboris.Res.html(
             req,
             "This route should take priority in the matcher.",
           );
      | (Naboris.Method.GET, ["html"]) =>
        Naboris.Res.status(200, res)
        |> Naboris.Res.html(
             req,
             "<!doctype html><html><body>You made it.</body></html>",
           );
      | (Naboris.Method.GET, ["user", _userId, "item", _itemId]) =>
        Naboris.Res.status(200, res)
        |> Naboris.Res.html(
             req,
             "<!doctype html><html><body>You want some user id and item</body></html>",
           );
      | (Naboris.Method.GET, ["echo-query", "query"]) =>
        echoQueryQuery(req, res, Naboris.Route.query(route));
      | (Naboris.Method.GET, ["echo", str]) =>
        Naboris.Res.status(200, res) |> Naboris.Res.html(req, str);
      | (Naboris.Method.GET, ["echo", str1, "multi", str2]) =>
        Naboris.Res.status(200, res)
        |> Naboris.Res.html(req, str1 ++ "\n" ++ str2);
      | (POST, ["echo"]) =>
        Lwt.bind(
          Naboris.Req.getBody(req),
          bodyStr => {
            Naboris.Res.status(200, res) |> Naboris.Res.html(req, bodyStr);
          },
        )
      | (POST, ["login"]) =>
        let (req2, res2, _sid) =
          Naboris.SessionManager.startSession(
            req,
            res,
            TestSession.{username: "realsessionuser"},
          );
        Naboris.Res.status(200, res2) |> Naboris.Res.text(req2, "OK");
      | (GET, ["logout"]) =>
        Naboris.SessionManager.removeSession(req, res)
          |> Naboris.Res.status(200)
          |> Naboris.Res.text(req, "OK");
      | (GET, ["who-am-i"]) =>
        switch (Naboris.Req.getSessionData(req)) {
        | None =>
          Naboris.Res.status(404, res) |> Naboris.Res.text(req, "Not found")
        | Some(userData) =>
          Naboris.Res.status(200, res)
          |> Naboris.Res.text(req, userData.username)
        };
      | (GET, ["redir-launch"]) =>
        Naboris.Res.redirect("/redir-landing", req, res);
      | (GET, ["redir-landing"]) =>
        Naboris.Res.status(200, res)
        |> Naboris.Res.text(req, "You have landed.");
      | (GET, ["test-json"]) =>
        Naboris.Res.status(200, res)
        |> Naboris.Res.json(req, "{\"test\": \"foo\"}");
      | (GET, ["test-raw"]) =>
        Naboris.Res.status(200, res)
        |> Naboris.Res.addHeader(("Content-Type", "application/xml"))
        |> Naboris.Res.raw(req, "<xml></xml>");
      | (GET, ["test-streaming"]) =>
        let (ch, return) = Naboris.Res.addHeader(("Content-Type", "text/html"), res)
          |> Naboris.Res.writeChannel(req);
        Lwt.async(() => Lwt_io.write(ch, "<html><head><title>Foo</title></head>")
          >>= (() => Lwt_io.flush(ch))
          >>= (() => Lwt_io.write(ch, "<body>Some data"))
          >>= (() => Lwt_io.write(ch, ". And more data.</body></html>"))
          >>= (() => Lwt_io.close(ch)));
        return;
      | (GET, ["error", "boys"]) =>
        Naboris.Res.reportError(SomebodyGoofed("Problems"), req, res);
      | _ =>
        Naboris.Res.status(404, res)
        |> Naboris.Res.html(
             req,
             "<!doctype html><html><body>Page not found</body></html>",
           );
      });

  let testServerConfig2: Naboris.ServerConfig.t(TestSession.t) = Naboris.ServerConfig.create()
    |> Naboris.ServerConfig.setOnListen(() => Lwt.wakeup_later(ssr2, ()))
    |> Naboris.ServerConfig.setRequestHandler((route, req, res) =>
      switch (Naboris.Route.meth(route), Naboris.Route.path(route)) {
      | _ =>
        Naboris.Res.status(404, res)
        |> Naboris.Res.html(
             req,
             "<!doctype html><html><body>Page not found</body></html>",
           );
      });

  // test the builder functions and middlewares
  let testServerConfig3: Naboris.ServerConfig.t(TestSession.t) = Naboris.ServerConfig.create()
    |> Naboris.ServerConfig.setSessionConfig(~sidKey="custom.sid", sessionConfig.getSession)
    |> Naboris.ServerConfig.addMiddleware((next, route, req, res) => {
      switch(Naboris.Route.path(route)) {
        | ["middleware", "one", _] =>
          res
            |> Naboris.Res.status(200)
            |> Naboris.Res.text(req, "middleware 1");
        | _ =>
          next(route, req, res);
      };
    })
    |> Naboris.ServerConfig.addMiddleware((next, route, req, res) => {
      switch(Naboris.Route.path(route)) {
        | ["middleware", "one", "never"] =>
          res
            |> Naboris.Res.status(200)
            |> Naboris.Res.text(req, "this should never happen");
        | ["middleware", "two"] =>
          res
            |> Naboris.Res.status(200)
            |> Naboris.Res.text(req, "middleware 2");
        | _ => next(route, req, res)
      }
    })
    |> Naboris.ServerConfig.setOnListen(() => Lwt.wakeup_later(ssr3, ()))
    |> Naboris.ServerConfig.setRequestHandler((route, req, res) => switch(Naboris.Route.path(route)) {
      | ["no", "middleware"] =>
        res
          |> Naboris.Res.status(200)
          |> Naboris.Res.text(req, "Regular router");
      | (["no", "middleware", "login"]) =>
        let (req2, res2, _sid) =
          Naboris.SessionManager.startSession(
            req,
            res,
            TestSession.{username: "realsessionuser"},
          );
        Naboris.Res.status(200, res2) |> Naboris.Res.text(req2, "OK");
      | _ =>
        res
          |> Naboris.Res.status(404)
          |> Naboris.Res.text(req, "Resource not found.");
    });
  let _foo2 = Naboris.listenAndWaitForever(9991, testServerConfig);
  Lwt.bind(ssp1, () => {
    Lwt.bind(
      Lwt_unix.sleep(1.0),
      () => {
        let _foo = Naboris.listenAndWaitForever(9992, testServerConfig2);
        Lwt.bind(ssp2, () => {
          Lwt.bind(
            Lwt_unix.sleep(1.0),
            () => {
              let _baz = Naboris.listenAndWaitForever(9993, testServerConfig3);
              ssp3;
            });
        });
      },
    )
  });
};

let testSuite = () => (
  "Integration Tests",
  [
    Alcotest_lwt.test_case("Start servers", `Slow, (lwtSwitch, _) => {
      startServers(lwtSwitch)
    }),
    Alcotest_lwt.test_case(
      "Get \"/this-should-never-exist\" returns a 404 by default",
      `Slow,
      (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/this-should-never-exist"),
      )
      >>= (
        ((resp, _bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "404 Not Found"));
          Lwt.return_unit;
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/this-should-never-exist\" returns a 404 by default",
      `Slow,
      (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9992/this-should-never-exist"),
      )
      >>= (
        ((resp, _bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "404 Not Found"));
          Lwt.return_unit;
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/html\" returns a 200 and html document", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(Uri.of_string("http://localhost:9991/html"))
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(
                check(
                  string,
                  "html body",
                  bodyStr,
                  "<!doctype html><html><body>You made it.</body></html>",
                )
              );
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/user/:userId/item/:itemId\" matches with integers",
      `Slow,
      (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/user/1/item/0"),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(
                check(
                  string,
                  "body string",
                  bodyStr,
                  "<!doctype html><html><body>You want some user id and item</body></html>",
                )
              );
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/user/:userId/item/:itemId\" matches with uuids",
      `Slow,
      (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string(
          "http://localhost:9991/user/bfdb66ad-f974-4293-acf9-dfda390abdc4/item/8f146ab9-94d1-46a9-bd0f-2079e22314f4",
        ),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(
                check(
                  string,
                  "html body",
                  bodyStr,
                  "<!doctype html><html><body>You want some user id and item</body></html>",
                )
              );
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/echo/:str\" matches and extracts param properly",
      `Slow,
      (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/echo/test 1"),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(check(string, "body", bodyStr, "test 1"));
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/echo/:str1/multi/:str2\" matches and extracts param(s) properly",
      `Slow,
      (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/echo/test 11/multi/test 2"),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(check(string, "body", bodyStr, "test 11\ntest 2"));
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/echo-query/query\" matches and extracts query params properly",
      `Slow,
      (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string(
          "http://localhost:9991/echo-query/query?q=foo&q2=bar&q3=baz",
        ),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(check(string, "body", bodyStr, "foo\nbar\nbaz"));
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/echo/pre-existing-route\" routes properly based on top to bottom priority",
      `Slow,
      (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/echo/pre-existing-route"),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(
                check(
                  string,
                  "body",
                  bodyStr,
                  "This route should take priority in the matcher.",
                )
              );
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Post \"/echo\" gets post body ast plain/text",
      `Slow,
      (_lwtSwitch, _) => {
        let expectedBody = "This is the string I expect to see from the body.";
        Cohttp_lwt_unix.Client.post(
          ~body=Cohttp_lwt.Body.of_string(expectedBody),
          Uri.of_string("http://localhost:9991/echo"),
        )
        >>= (
          ((resp, bod)) => {
            let codeStr = Cohttp.Code.string_of_status(resp.status);
            Alcotest.(check(string, "status", codeStr, "200 OK"));
            Cohttp_lwt.Body.to_string(bod)
            >>= (
              bodyStr => {
                Alcotest.(check(string, "body", bodyStr, expectedBody));
                Lwt.return_unit;
              }
            );
          }
        );
      },
    ),
    Alcotest_lwt.test_case(
      "Get \"/static/:file_path\" matches and extracts query params properly",
      `Slow,
      (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/static/text/text_file.txt"),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(check(string, "body", bodyStr, "Hello world!"));
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/static/:file_path\" gets files bigger than 512B",
      `Slow,
      (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/static/text/1024.txt"),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(check(int, "length", String.length(bodyStr), 1024));
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/static/:file_path\" returns 404 when file not found",
      `Slow,
      (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string(
          "http://localhost:9991/static/no/such/path/I_DO_NOT_EXIST",
        ),
      )
      >>= (
        ((resp, _)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "404 Not Found"));
          Lwt.return_unit;
        }
      )
    }),
    Alcotest_lwt.test_case("Can start a session", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.post(
        Uri.of_string("http://localhost:9991/login"),
      )
      >>= (
        ((resp, _bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));

          let headers = resp |> Cohttp.Response.headers;
          switch (Cohttp.Header.get(headers, "Set-Cookie")) {
          | Some(cookie) =>
            Alcotest.(
              check(string, "id", String.sub(cookie, 0, 7), "nab.sid")
            )
          | None => Alcotest.(check(bool, "fail", false, true))
          };
          Lwt.return_unit;
        }
      )
    }),
    Alcotest_lwt.test_case("Handle no session", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/who-am-i"),
      )
      >>= (
        ((resp, _bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "404 Not Found"));
          Lwt.return_unit;
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Access session data across multiple requests", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.post(
        Uri.of_string("http://localhost:9991/login"),
      )
      >>= (
        ((resp, _bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));

          let headers = Cohttp.Response.headers(resp);
          switch (Cohttp.Header.get(headers, "Set-Cookie")) {
          | Some(_cookie) =>
            let cookie = "_ga=GA1.1.1652070095.1563853850; express.sid=s%3AhSEgvCCmOADa-0Flv4ulT1FltA8TzHeq.G1UoU2xXC8X8wkEO5I0J%2BhE3NCjUoggAlGnz0jA1%2B2w; _gid=GA1.1.1409339010.1564626384; connect.sid=s%3AClROuVLX_Dalzkmf0D4d0Xath-HHG16M.8zaxTWykLFnypEw%2BCAIZRTPJR7IKBDUcAamWUch4Czk; nab.sid=67f67df4c5d9711ef89bbf8b509d49e2cc1ce51e3d95c90d45485a7b3cf40ca4ec9cbbceb0ca6ad844ec4a4779fd9981b130c40f81646f2ef286749c7184e66f";
            let headers2 = Cohttp.Header.init_with("Cookie", cookie);
            Cohttp_lwt_unix.Client.get(
              ~headers=headers2,
              Uri.of_string("http://localhost:9991/who-am-i"),
            )
            >>= (
              ((resp2, bod)) => {
                let codeStr = Cohttp.Code.string_of_status(resp2.status);
                Alcotest.(check(string, "status", codeStr, "200 OK"));
                Cohttp_lwt.Body.to_string(bod)
                >>= (
                  bodyStr => {
                    Alcotest.(
                      check(string, "body", bodyStr, "realsessionuser")
                    );
                    Lwt.return_unit;
                  }
                );
              }
            );
          | None =>
            Alcotest.(check(bool, "failed", false, true));
            Lwt.return_unit;
          };
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Can remove session cookies", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.post(
        Uri.of_string("http://localhost:9991/login"),
      )
      >>= (
        ((resp, _bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));

          let headers = Cohttp.Response.headers(resp);
          switch (Cohttp.Header.get(headers, "Set-Cookie")) {
          | Some(_cookie) =>
            let cookie = "_ga=GA1.1.1652070095.1563853850; express.sid=s%3AhSEgvCCmOADa-0Flv4ulT1FltA8TzHeq.G1UoU2xXC8X8wkEO5I0J%2BhE3NCjUoggAlGnz0jA1%2B2w; _gid=GA1.1.1409339010.1564626384; connect.sid=s%3AClROuVLX_Dalzkmf0D4d0Xath-HHG16M.8zaxTWykLFnypEw%2BCAIZRTPJR7IKBDUcAamWUch4Czk; nab.sid=67f67df4c5d9711ef89bbf8b509d49e2cc1ce51e3d95c90d45485a7b3cf40ca4ec9cbbceb0ca6ad844ec4a4779fd9981b130c40f81646f2ef286749c7184e66f";
            let headers2 = Cohttp.Header.init_with("Cookie", cookie);
            Cohttp_lwt_unix.Client.get(
              ~headers=headers2,
              Uri.of_string("http://localhost:9991/logout"),
            )
            >>= (
              ((resp2, _bod)) => {
                let codeStr = Cohttp.Code.string_of_status(resp2.status);
                Alcotest.(check(string, "status", codeStr, "200 OK"));
                let logoutHeaders = Cohttp.Response.headers(resp2);
                switch (Cohttp.Header.get(logoutHeaders, "Set-Cookie")) {
                  | Some(setCookie) =>
                    Alcotest.(check(string, "set header", "nab.sid=; Max-Age=0;", setCookie));
                    Lwt.return_unit;
                  | None =>
                    Alcotest.(check(bool, "failed", false, true));
                    Lwt.return_unit;
                }
              }
            );
          | None =>
            Alcotest.(check(bool, "failed", false, true));
            Lwt.return_unit;
          };
        }
      )
    }),
    Alcotest_lwt.test_case("Redirects properly", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/redir-launch"),
      )
      >>= (
        ((resp, _bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "302 Found"));
          Alcotest.(
            check(
              option(string),
              "redirect",
              Cohttp.Header.get(resp.headers, "Location"),
              Some("/redir-landing"),
            )
          );
          Lwt.return_unit;
        }
      )
    }),
    Alcotest_lwt.test_case("Report error returns 500", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/error/boys"),
      )
      >>= (
        ((resp, _bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(
            check(string, "status", codeStr, "500 Internal Server Error")
          );
          Lwt.return_unit;
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/json-test\" sends json header", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/test-json"),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(
            check(
              option(string),
              "content type",
              Cohttp.Header.get(resp.headers, "Content-type"),
              Some("application/json"),
            )
          );
          Alcotest.(check(string, "status", codeStr, "200 OK"));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(
                check(string, "body", bodyStr, "{\"test\": \"foo\"}")
              );
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/raw-test\" sends xml header", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/test-raw"),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(
            check(
              option(string),
              "content type",
              Cohttp.Header.get(resp.headers, "Content-type"),
              Some("application/xml"),
            )
          );
          Alcotest.(check(string, "status", codeStr, "200 OK"));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(check(string, "body", bodyStr, "<xml></xml>"));
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Get \"/test-streaming\" sends chunked header and data", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/test-streaming"),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(
            check(
              option(string),
              "transfer encoding",
              Cohttp.Header.get(resp.headers, "transfer-encoding"),
              Some("chunked"),
            )
          );
          Alcotest.(
            check(
              option(string),
              "no content length",
              Cohttp.Header.get(resp.headers, "content-length"),
              None,
            )
          );
          Alcotest.(
            check(
              option(string),
              "keep alive",
              Cohttp.Header.get(resp.headers, "connection"),
              Some("keep-alive"),
            )
          );
          Alcotest.(check(string, "status", codeStr, "200 OK"));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(check(string, "body", bodyStr, "<html><head><title>Foo</title></head><body>Some data. And more data.</body></html>"));
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Middleware - Get \"/middleware/one/never\" should be served by the first middleware", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9993/middleware/one/never"),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(
            check(
              option(string),
              "content type",
              Some("text/plain"),
              Cohttp.Header.get(resp.headers, "Content-type"),
            )
          );
          Alcotest.(check(string, "status", "200 OK", codeStr));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(check(string, "body", "middleware 1", bodyStr));
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Middleware - Get \"/middleware/two\" should be served by the second middleware", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9993/middleware/two"),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(
            check(
              option(string),
              "content type",
              Some("text/plain"),
              Cohttp.Header.get(resp.headers, "Content-type"),
            )
          );
          Alcotest.(check(string, "status", "200 OK", codeStr));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(check(string, "body", "middleware 2", bodyStr));
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case(
      "Middleware - Get \"/no/middleware\" should be served by the route handler", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9993/no/middleware"),
      )
      >>= (
        ((resp, bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(
            check(
              option(string),
              "content type",
              Some("text/plain"),
              Cohttp.Header.get(resp.headers, "Content-type"),
            )
          );
          Alcotest.(check(string, "status", "200 OK", codeStr));
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              Alcotest.(check(string, "body", "Regular router", bodyStr));
              Lwt.return_unit;
            }
          );
        }
      )
    }),
    Alcotest_lwt.test_case("Can start a session with custom cookie key", `Slow, (_lwtSwitch, _) => {
      Cohttp_lwt_unix.Client.post(
        Uri.of_string("http://localhost:9993/no/middleware/login"),
      )
      >>= (
        ((resp, _bod)) => {
          let codeStr = Cohttp.Code.string_of_status(resp.status);
          Alcotest.(check(string, "status", codeStr, "200 OK"));

          let headers = resp |> Cohttp.Response.headers;
          switch (Cohttp.Header.get(headers, "Set-Cookie")) {
          | Some(cookie) =>
            Alcotest.(
              check(string, "id", String.sub(cookie, 0, 10), "custom.sid")
            )
          | None => Alcotest.(check(bool, "fail", false, true))
          };
          Lwt.return_unit;
        }
      )
    }),
  ],
);