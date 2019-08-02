open Lwt.Infix;

let tests = [
  Spec.{
    title: "Get \"/this-should-never-exist\" returns a 404 by default",
    test: () => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/this-should-never-exist"),
      )
      >>= (
        ((resp, _bod)) => {
          assert(resp.status == `Not_found);
          Lwt.return((TestResult.TestDone, 0.0));
        }
      );
    },
  },
  Spec.{
    title: "Get \"/html\" returns a 200 and html document",
    test: () => {
      Cohttp_lwt_unix.Client.get(Uri.of_string("http://localhost:9991/html"))
      >>= (
        ((resp, bod)) => {
          assert(resp.status == `OK);
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              assert(
                bodyStr
                == "<!doctype html><html><body>You made it.</body></html>",
              );
              Lwt.return((TestResult.TestDone, 0.0));
            }
          );
        }
      );
    },
  },
  Spec.{
    title: "Get \"/user/:userId/item/:itemId\" matches with integers",
    test: () => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/user/1/item/0"),
      )
      >>= (
        ((resp, bod)) => {
          assert(resp.status == `OK);
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              assert(
                bodyStr
                == "<!doctype html><html><body>You want some user id and item</body></html>",
              );
              Lwt.return((TestResult.TestDone, 0.0));
            }
          );
        }
      );
    },
  },
  Spec.{
    title: "Get \"/user/:userId/item/:itemId\" matches with uuids",
    test: () => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string(
          "http://localhost:9991/user/bfdb66ad-f974-4293-acf9-dfda390abdc4/item/8f146ab9-94d1-46a9-bd0f-2079e22314f4",
        ),
      )
      >>= (
        ((resp, bod)) => {
          assert(resp.status == `OK);
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              assert(
                bodyStr
                == "<!doctype html><html><body>You want some user id and item</body></html>",
              );
              Lwt.return((TestResult.TestDone, 0.0));
            }
          );
        }
      );
    },
  },
  Spec.{
    title: "Get \"/echo/:str\" matches and extracts param properly",
    test: () => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/echo/test 1"),
      )
      >>= (
        ((resp, bod)) => {
          assert(resp.status == `OK);
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              AssertString.areSame(bodyStr, "test 1");
              Lwt.return((TestResult.TestDone, 0.0));
            }
          );
        }
      );
    },
  },
  Spec.{
    title: "Get \"/echo/:str1/multi/:str2\" matches and extracts param(s) properly",
    test: () => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/echo/test 11/multi/test 2"),
      )
      >>= (
        ((resp, bod)) => {
          assert(resp.status == `OK);
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              AssertString.areSame(bodyStr, "test 11\ntest 2");
              Lwt.return((TestResult.TestDone, 0.0));
            }
          );
        }
      );
    },
  },
  Spec.{
    title: "Get \"/echo-query/query\" matches and extracts query params properly",
    test: () => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string(
          "http://localhost:9991/echo-query/query?q=foo&q2=bar&q3=baz",
        ),
      )
      >>= (
        ((resp, bod)) => {
          assert(resp.status == `OK);
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              AssertString.areSame(bodyStr, "foo\nbar\nbaz");
              Lwt.return((TestResult.TestDone, 0.0));
            }
          );
        }
      );
    },
  },
  Spec.{
    title: "Get \"/echo/pre-existing-route\" routes properly based on top to bottom priority",
    test: () => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/echo/pre-existing-route"),
      )
      >>= (
        ((resp, bod)) => {
          assert(resp.status == `OK);
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              AssertString.areSame(
                bodyStr,
                "This route should take priority in the matcher.",
              );
              Lwt.return((TestResult.TestDone, 0.0));
            }
          );
        }
      );
    },
  },
  Spec.{
    title: "Post \"/echo\" gets post body ast plain/text",
    test: () => {
      let expectedBody = "This is the string I expect to see from the body.";
      Cohttp_lwt_unix.Client.post(
        ~body=Cohttp_lwt.Body.of_string(expectedBody),
        Uri.of_string("http://localhost:9991/echo"),
      )
      >>= (
        ((resp, bod)) => {
          assert(resp.status == `OK);
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              AssertString.areSame(bodyStr, expectedBody);
              Lwt.return((TestResult.TestDone, 0.0));
            }
          );
        }
      );
    },
  },
  Spec.{
    title: "Get \"/static/:file_path\" matches and extracts query params properly",
    test: () => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/static/text/text_file.txt"),
      )
      >>= (
        ((resp, bod)) => {
          assert(resp.status == `OK);
          Cohttp_lwt.Body.to_string(bod)
          >>= (
            bodyStr => {
              AssertString.areSame(bodyStr, "Hello world!");
              Lwt.return((TestResult.TestDone, 0.0));
            }
          );
        }
      );
    },
  },
  Spec.{
    title: "Get \"/static/:file_path\" returns 404 when file not found",
    test: () => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string(
          "http://localhost:9991/static/no/such/path/I_DO_NOT_EXIST",
        ),
      )
      >>= (
        ((resp, _)) => {
          assert(resp.status == `Not_found);
          Lwt.return((TestResult.TestDone, 0.0));
        }
      );
    },
  },
  Spec.{
    title: "Can start a session",
    test: () => {
      Cohttp_lwt_unix.Client.post(
        Uri.of_string("http://localhost:9991/login"),
      )
      >>= (
        ((resp, _bod)) => {
          assert(resp.status == `OK);
          let headers = resp |> Cohttp.Response.headers;
          switch (Cohttp.Header.get(headers, "Set-Cookie")) {
          | Some(cookie) => assert(String.sub(cookie, 0, 7) == "nab.sid")
          | None => assert(false == true)
          };
          Lwt.return((TestResult.TestDone, 0.0));
        }
      );
    },
  },
  Spec.{
    title: "Handle no session",
    test: () => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/who-am-i"),
      )
      >>= (
        ((resp, _bod)) => {
          assert(resp.status == `Not_found);
          Lwt.return((TestResult.TestDone, 0.0));
        }
      );
    },
  },
  Spec.{
    title: "Access session data across multiple requests",
    test: () => {
      Cohttp_lwt_unix.Client.post(
        Uri.of_string("http://localhost:9991/login"),
      )
      >>= (
        ((resp, _bod)) => {
          assert(resp.status == `OK);
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
                assert(resp2.status == `OK);
                Cohttp_lwt.Body.to_string(bod)
                >>= (
                  bodyStr => {
                    AssertString.areSame(bodyStr, "realsessionuser");
                    Lwt.return((TestResult.TestDone, 0.0));
                  }
                );
              }
            );
          | None =>
            assert(false == true);
            Lwt.return((TestResult.TestDone, 0.0));
          };
        }
      );
    },
  },
  Spec.{
    title: "Redirects properly",
    test: () => {
      Cohttp_lwt_unix.Client.get(
        Uri.of_string("http://localhost:9991/redir-launch"),
      )
      >>= (
        ((resp, _bod)) => {
          assert(resp.status == `Found);
          switch (Cohttp.Header.get(resp.headers, "Location")) {
          | Some(loc) => assert(loc == "/redir-landing")
          | _ => assert(false == true)
          };
          Lwt.return((TestResult.TestDone, 0.0));
        }
      );
    },
  },
];