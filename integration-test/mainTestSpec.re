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
];