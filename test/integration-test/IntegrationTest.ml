open Lwt.Infix

exception SomebodyGoofed of string

let echoQueryQuery req res query =
  let maybeStr1 = Naboris.Query.QueryMap.find_opt "q" query in
  let maybeStr2 = Naboris.Query.QueryMap.find_opt "q2" query in
  let maybeStr3 = Naboris.Query.QueryMap.find_opt "q3" query in

  let vals = [maybeStr1; maybeStr2; maybeStr3] in

  match vals with
  | [Some (str1 :: _); Some (str2 :: _); Some (str3 :: _)] ->
    Naboris.Res.status 200 res
    |> Naboris.Res.html req (str1 ^ "\n" ^ str2 ^ "\n" ^ str3)
  | _ -> Naboris.Res.status 500 res |> Naboris.Res.html req "fail"

let sessionConfig : TestSession.t Naboris.SessionConfig.t = {
  sidKey = "nab.sid";
  secret = "Keep it secret, keep it safe!";
  maxAge = 3600;
  getSession = (fun sessionId ->
    let userData = TestSession.{username = "realsessionuser"} in
    match sessionId with
    | Some sid -> Lwt.return (Some (Naboris.Session.create sid userData))
    | _ -> Lwt.return None);
}

let startServers lwtSwitch =
  let (ssp1, ssr1) = Lwt.task () in
  let (ssp2, ssr2) = Lwt.task () in
  let (ssp3, ssr3) = Lwt.task () in

  Lwt_switch.add_hook
    (Some lwtSwitch)
    (fun () ->
      Lwt.cancel ssp1;
      Lwt.cancel ssp2;
      Lwt.return_unit);

  let testServerConfig : TestSession.t Naboris.ServerConfig.t =
    Naboris.ServerConfig.create ()
    |> Naboris.ServerConfig.setOnListen (fun () -> Lwt.wakeup_later ssr1 ())
    |> Naboris.ServerConfig.setSessionConfig sessionConfig.getSession
    |> Naboris.ServerConfig.addStaticMiddleware
         ["static"]
         (Sys.getcwd () ^ "/../../../test/integration-test/test_assets")
    |> Naboris.ServerConfig.setErrorHandler (fun error _route ->
         match error with
         | SomebodyGoofed _ -> Lwt.return ([], "Dude, somebody goofed")
         | _ -> Lwt.return ([], "else"))
    |> Naboris.ServerConfig.setRequestHandler (fun route req res ->
         match (Naboris.Route.meth route, Naboris.Route.path route) with
         | (Naboris.Method.GET, ["echo"; "pre-existing-route"]) ->
           Naboris.Res.status 200 res
           |> Naboris.Res.html
                req
                "This route should take priority in the matcher."
         | (Naboris.Method.GET, ["html"]) ->
           Naboris.Res.status 200 res
           |> Naboris.Res.html
                req
                "<!doctype html><html><body>You made it.</body></html>"
         | (Naboris.Method.GET, ["user"; _userId; "item"; _itemId]) ->
           Naboris.Res.status 200 res
           |> Naboris.Res.html
                req
                "<!doctype html><html><body>You want some user id and item</body></html>"
         | (Naboris.Method.GET, ["echo-query"; "query"]) ->
           echoQueryQuery req res (Naboris.Route.query route)
         | (Naboris.Method.GET, ["echo"; str]) ->
           Naboris.Res.status 200 res |> Naboris.Res.html req str
         | (Naboris.Method.GET, ["echo"; str1; "multi"; str2]) ->
           Naboris.Res.status 200 res
           |> Naboris.Res.html req (str1 ^ "\n" ^ str2)
         | (POST, ["echo"]) ->
           Lwt.bind (Naboris.Req.getBody req) (fun bodyStr ->
             Naboris.Res.status 200 res |> Naboris.Res.html req bodyStr)
         | (POST, ["login"]) ->
           let (req2, res2, _sid) =
             Naboris.SessionManager.startSession
               req
               res
               TestSession.{username = "realsessionuser"}
           in
           Naboris.Res.status 200 res2 |> Naboris.Res.text req2 "OK"
         | (GET, ["logout"]) ->
           Naboris.SessionManager.removeSession req res
           |> Naboris.Res.status 200
           |> Naboris.Res.text req "OK"
         | (GET, ["who-am-i"]) ->
           (match Naboris.Req.getSessionData req with
           | None ->
             Naboris.Res.status 404 res
             |> Naboris.Res.text req "Not found"
           | Some userData ->
             Naboris.Res.status 200 res
             |> Naboris.Res.text req userData.username)
         | (GET, ["redir-launch"]) ->
           Naboris.Res.redirect "/redir-landing" req res
         | (GET, ["redir-landing"]) ->
           Naboris.Res.status 200 res
           |> Naboris.Res.text req "You have landed."
         | (GET, ["test-json"]) ->
           Naboris.Res.status 200 res
           |> Naboris.Res.json req "{\"test\": \"foo\"}"
         | (GET, ["test-raw"]) ->
           Naboris.Res.status 200 res
           |> Naboris.Res.addHeader ("Content-Type", "application/xml")
           |> Naboris.Res.raw req "<xml></xml>"
         | (GET, ["test-streaming"]) ->
           let (ch, return) =
             Naboris.Res.addHeader ("Content-Type", "text/html") res
             |> Naboris.Res.writeChannel req
           in
           Lwt.async (fun () ->
             Lwt_io.write ch "<html><head><title>Foo</title></head>"
             >>= (fun () -> Lwt_io.flush ch)
             >>= (fun () -> Lwt_io.write ch "<body>Some data")
             >>= (fun () -> Lwt_io.write ch ". And more data.</body></html>")
             >>= (fun () -> Lwt_io.close ch));
           return
         | (GET, ["error"; "boys"]) ->
           Naboris.Res.reportError (SomebodyGoofed "Problems") req res
         | _ ->
           Naboris.Res.status 404 res
           |> Naboris.Res.html
                req
                "<!doctype html><html><body>Page not found</body></html>") in

  let testServerConfig2 : TestSession.t Naboris.ServerConfig.t =
    Naboris.ServerConfig.create ()
    |> Naboris.ServerConfig.setOnListen (fun () -> Lwt.wakeup_later ssr2 ())
    |> Naboris.ServerConfig.setRequestHandler (fun route req res ->
         match (Naboris.Route.meth route, Naboris.Route.path route) with
         | _ ->
           Naboris.Res.status 404 res
           |> Naboris.Res.html
                req
                "<!doctype html><html><body>Page not found</body></html>") in

  (* test the builder functions and middlewares *)
  let testServerConfig3 : TestSession.t Naboris.ServerConfig.t =
    Naboris.ServerConfig.create ()
    |> Naboris.ServerConfig.setSessionConfig
         ~sidKey:"custom.sid"
         sessionConfig.getSession
    |> Naboris.ServerConfig.addMiddleware (fun next route req res ->
         match Naboris.Route.path route with
         | ["middleware"; "one"; _] ->
           res
           |> Naboris.Res.status 200
           |> Naboris.Res.text req "middleware 1"
         | _ -> next route req res)
    |> Naboris.ServerConfig.addMiddleware (fun next route req res ->
         match Naboris.Route.path route with
         | ["middleware"; "one"; "never"] ->
           res
           |> Naboris.Res.status 200
           |> Naboris.Res.text req "this should never happen"
         | ["middleware"; "two"] ->
           res
           |> Naboris.Res.status 200
           |> Naboris.Res.text req "middleware 2"
         | _ -> next route req res)
    |> Naboris.ServerConfig.setOnListen (fun () -> Lwt.wakeup_later ssr3 ())
    |> Naboris.ServerConfig.setRequestHandler (fun route req res ->
         match Naboris.Route.path route with
         | ["no"; "middleware"] ->
           res
           |> Naboris.Res.status 200
           |> Naboris.Res.text req "Regular router"
         | ["no"; "middleware"; "login"] ->
           let (req2, res2, _sid) =
             Naboris.SessionManager.startSession
               req
               res
               TestSession.{username = "realsessionuser"}
           in
           Naboris.Res.status 200 res2 |> Naboris.Res.text req2 "OK"
         | _ ->
           res
           |> Naboris.Res.status 404
           |> Naboris.Res.text req "Resource not found.") in
  let _foo2 = Naboris.listenAndWaitForever 9991 testServerConfig in
  Lwt.bind ssp1 (fun () ->
    Lwt.bind
      (Lwt_unix.sleep 1.0)
      (fun () ->
        let _foo = Naboris.listenAndWaitForever 9992 testServerConfig2 in
        Lwt.bind ssp2 (fun () ->
          Lwt.bind
            (Lwt_unix.sleep 1.0)
            (fun () ->
              let _baz =
                Naboris.listenAndWaitForever 9993 testServerConfig3
              in
              ssp3))))

let testSuite () = (
  "Integration Tests",
  [
    Alcotest_lwt.test_case "Start servers" `Slow (fun lwtSwitch _ ->
      startServers lwtSwitch);
    Alcotest_lwt.test_case
      "Get \"/this-should-never-exist\" returns a 404 by default"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/this-should-never-exist")
      >>= (fun (resp, _bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "404 Not Found");
          Lwt.return_unit));
    Alcotest_lwt.test_case
      "Get \"/this-should-never-exist\" returns a 404 by default"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9992/this-should-never-exist")
      >>= (fun (resp, _bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "404 Not Found");
          Lwt.return_unit));
    Alcotest_lwt.test_case
      "Get \"/html\" returns a 200 and html document" `Slow (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get (Uri.of_string "http://localhost:9991/html")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(
                check
                  string
                  "html body"
                  bodyStr
                  "<!doctype html><html><body>You made it.</body></html>");
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Get \"/user/:userId/item/:itemId\" matches with integers"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/user/1/item/0")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(
                check
                  string
                  "body string"
                  bodyStr
                  "<!doctype html><html><body>You want some user id and item</body></html>");
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Get \"/user/:userId/item/:itemId\" matches with uuids"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string
          "http://localhost:9991/user/bfdb66ad-f974-4293-acf9-dfda390abdc4/item/8f146ab9-94d1-46a9-bd0f-2079e22314f4")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(
                check
                  string
                  "html body"
                  bodyStr
                  "<!doctype html><html><body>You want some user id and item</body></html>");
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Get \"/echo/:str\" matches and extracts param properly"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/echo/test 1")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(check string "body" bodyStr "test 1");
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Get sets headers properly"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/echo/test 1")
      >>= (fun (resp, _bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          let dateHeader = Cohttp.Header.get (Cohttp.Response.headers resp) "date" in
          let hasDate = match dateHeader with
            | None -> false
            | _ -> true
          in
          let etag = Cohttp.Header.get (Cohttp.Response.headers resp) "etag" in
          let hasEtag = match etag with
            | None -> false
            | _ -> true
          in
          Alcotest.(check string "status" codeStr "200 OK");
          Alcotest.(check bool "has date header" hasDate true);
          Alcotest.(check bool "has etag header" hasEtag true);
          Lwt.return_unit));
    Alcotest_lwt.test_case
      "Get \"/echo/:str1/multi/:str2\" matches and extracts param(s) properly"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/echo/test 11/multi/test 2")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(check string "body" bodyStr "test 11\ntest 2");
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Get \"/echo-query/query\" matches and extracts query params properly"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string
          "http://localhost:9991/echo-query/query?q=foo&q2=bar&q3=baz")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(check string "body" bodyStr "foo\nbar\nbaz");
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Get \"/echo/pre-existing-route\" routes properly based on top to bottom priority"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/echo/pre-existing-route")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(
                check
                  string
                  "body"
                  bodyStr
                  "This route should take priority in the matcher.");
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Post \"/echo\" gets post body ast plain/text"
      `Slow
      (fun _lwtSwitch _ ->
        let expectedBody = "This is the string I expect to see from the body." in
        Cohttp_lwt_unix.Client.post
          ~body:(Cohttp_lwt.Body.of_string expectedBody)
          (Uri.of_string "http://localhost:9991/echo")
        >>= (fun (resp, bod) ->
            let codeStr = Cohttp.Code.string_of_status resp.status in
            Alcotest.(check string "status" codeStr "200 OK");
            Cohttp_lwt.Body.to_string bod
            >>= (fun bodyStr ->
                Alcotest.(check string "body" bodyStr expectedBody);
                Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Get \"/static/:file_path\" matches and extracts query params properly"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/static/text/text_file.txt")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(check string "body" bodyStr "Hello world!");
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Get static files sends correct headers"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/static/text/text_file.txt")
      >>= (fun (resp, _bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");
          let headers = Cohttp.Response.headers resp in
          let cacheControl = Cohttp.Header.get headers "cache-control" in
          let lastModified = Cohttp.Header.get headers "last-modified" in
          let hasLastModified = match lastModified with
            | Some _ -> true
            | None -> false
          in
          let etag = Cohttp.Header.get headers "etag" in
          let hasEtag = match etag with
            | Some _ -> true
            | None -> false
          in
          Alcotest.(check (option string) "cache-control" cacheControl (Some "public, max-age=0"));
          Alcotest.(check bool "has last-modified" hasLastModified true);
          Alcotest.(check bool "has etag" hasEtag true);
          Lwt.return_unit));
    Alcotest_lwt.test_case
      "Get \"/static/:file_path\" gets files bigger than 512B"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/static/text/1024.txt")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(check int "length" (String.length bodyStr) 1024);
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Get \"/static/:file_path\" returns 404 when file not found"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string
          "http://localhost:9991/static/no/such/path/I_DO_NOT_EXIST")
      >>= (fun (resp, _) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "404 Not Found");
          Lwt.return_unit));
    Alcotest_lwt.test_case "Can start a session" `Slow (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.post
        (Uri.of_string "http://localhost:9991/login")
      >>= (fun (resp, _bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");

          let headers = resp |> Cohttp.Response.headers in
          (match Cohttp.Header.get headers "Set-Cookie" with
          | Some cookie ->
            Alcotest.(
              check string "id" (String.sub cookie 0 7) "nab.sid")
          | None -> Alcotest.(check bool "fail" false true));
          Lwt.return_unit));
    Alcotest_lwt.test_case "Handle no session" `Slow (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/who-am-i")
      >>= (fun (resp, _bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "404 Not Found");
          Lwt.return_unit));
    Alcotest_lwt.test_case
      "Access session data across multiple requests" `Slow (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.post
        (Uri.of_string "http://localhost:9991/login")
      >>= (fun (resp, _bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");

          let headers = Cohttp.Response.headers resp in
          match Cohttp.Header.get headers "Set-Cookie" with
          | Some cookie ->
            let cookie = "_ga=GA1.1.1652070095.1563853850; express.sid=s%3AhSEgvCCmOADa-0Flv4ulT1FltA8TzHeq.G1UoU2xXC8X8wkEO5I0J%2BhE3NCjUoggAlGnz0jA1%2B2w; _gid=GA1.1.1409339010.1564626384; connect.sid=s%3AClROuVLX_Dalzkmf0D4d0Xath-HHG16M.8zaxTWykLFnypEw%2BCAIZRTPJR7IKBDUcAamWUch4Czk; " ^ cookie in
            let headers2 = Cohttp.Header.init_with "Cookie" cookie in
            Cohttp_lwt_unix.Client.get
              ~headers:headers2
              (Uri.of_string "http://localhost:9991/who-am-i")
            >>= (fun (resp2, bod) ->
                let codeStr = Cohttp.Code.string_of_status resp2.status in
                Alcotest.(check string "status" codeStr "200 OK");
                Cohttp_lwt.Body.to_string bod
                >>= (fun bodyStr ->
                    Alcotest.(
                      check string "body" bodyStr "realsessionuser");
                    Lwt.return_unit))
          | None ->
            Alcotest.(check bool "failed" false true);
            Lwt.return_unit));
    Alcotest_lwt.test_case
      "Can remove session cookies" `Slow (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.post
        (Uri.of_string "http://localhost:9991/login")
      >>= (fun (resp, _bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");

          let headers = Cohttp.Response.headers resp in
          match Cohttp.Header.get headers "Set-Cookie" with
          | Some _cookie ->
            let cookie = "_ga=GA1.1.1652070095.1563853850; express.sid=s%3AhSEgvCCmOADa-0Flv4ulT1FltA8TzHeq.G1UoU2xXC8X8wkEO5I0J%2BhE3NCjUoggAlGnz0jA1%2B2w; _gid=GA1.1.1409339010.1564626384; connect.sid=s%3AClROuVLX_Dalzkmf0D4d0Xath-HHG16M.8zaxTWykLFnypEw%2BCAIZRTPJR7IKBDUcAamWUch4Czk; nab.sid=67f67df4c5d9711ef89bbf8b509d49e2cc1ce51e3d95c90d45485a7b3cf40ca4ec9cbbceb0ca6ad844ec4a4779fd9981b130c40f81646f2ef286749c7184e66f" in
            let headers2 = Cohttp.Header.init_with "Cookie" cookie in
            Cohttp_lwt_unix.Client.get
              ~headers:headers2
              (Uri.of_string "http://localhost:9991/logout")
            >>= (fun (resp2, _bod) ->
                let codeStr = Cohttp.Code.string_of_status resp2.status in
                Alcotest.(check string "status" codeStr "200 OK");
                let logoutHeaders = Cohttp.Response.headers resp2 in
                match Cohttp.Header.get logoutHeaders "Set-Cookie" with
                | Some setCookie ->
                  Alcotest.(
                    check
                      string
                      "set header"
                      "nab.sid=; Max-Age=0;"
                      setCookie);
                  Lwt.return_unit
                | None ->
                  Alcotest.(check bool "failed" false true);
                  Lwt.return_unit)
          | None ->
            Alcotest.(check bool "failed" false true);
            Lwt.return_unit));
    Alcotest_lwt.test_case "Redirects properly" `Slow (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/redir-launch")
      >>= (fun (resp, _bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "302 Found");
          Alcotest.(
            check
              (option string)
              "redirect"
              (Cohttp.Header.get resp.headers "Location")
              (Some "/redir-landing"));
          Lwt.return_unit));
    Alcotest_lwt.test_case "Report error returns 500" `Slow (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/error/boys")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(
            check string "status" codeStr "500 Internal Server Error");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(
                check string "body" bodyStr "Dude, somebody goofed");
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Get \"/json-test\" sends json header" `Slow (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/test-json")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(
            check
              (option string)
              "content type"
              (Cohttp.Header.get resp.headers "Content-type")
              (Some "application/json"));
          Alcotest.(check string "status" codeStr "200 OK");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(
                check string "body" bodyStr "{\"test\": \"foo\"}");
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Get \"/raw-test\" sends xml header" `Slow (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/test-raw")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(
            check
              (option string)
              "content type"
              (Cohttp.Header.get resp.headers "Content-type")
              (Some "application/xml"));
          Alcotest.(check string "status" codeStr "200 OK");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(check string "body" bodyStr "<xml></xml>");
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Get \"/test-streaming\" sends chunked header and data"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9991/test-streaming")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(
            check
              (option string)
              "transfer encoding"
              (Cohttp.Header.get resp.headers "transfer-encoding")
              (Some "chunked"));
          Alcotest.(
            check
              (option string)
              "no content length"
              (Cohttp.Header.get resp.headers "content-length")
              None);
          Alcotest.(
            check
              (option string)
              "keep alive"
              (Cohttp.Header.get resp.headers "connection")
              (Some "keep-alive"));
          Alcotest.(check string "status" codeStr "200 OK");
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(
                check
                  string
                  "body"
                  bodyStr
                  "<html><head><title>Foo</title></head><body>Some data. And more data.</body></html>");
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Middleware - Get \"/middleware/one/never\" should be served by the first middleware"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9993/middleware/one/never")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(
            check
              (option string)
              "content type"
              (Some "text/plain")
              (Cohttp.Header.get resp.headers "Content-type"));
          Alcotest.(check string "status" "200 OK" codeStr);
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(check string "body" "middleware 1" bodyStr);
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Middleware - Get \"/middleware/two\" should be served by the second middleware"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9993/middleware/two")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(
            check
              (option string)
              "content type"
              (Some "text/plain")
              (Cohttp.Header.get resp.headers "Content-type"));
          Alcotest.(check string "status" "200 OK" codeStr);
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(check string "body" "middleware 2" bodyStr);
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Middleware - Get \"/no/middleware\" should be served by the route handler"
      `Slow
      (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.get
        (Uri.of_string "http://localhost:9993/no/middleware")
      >>= (fun (resp, bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(
            check
              (option string)
              "content type"
              (Some "text/plain")
              (Cohttp.Header.get resp.headers "Content-type"));
          Alcotest.(check string "status" "200 OK" codeStr);
          Cohttp_lwt.Body.to_string bod
          >>= (fun bodyStr ->
              Alcotest.(check string "body" "Regular router" bodyStr);
              Lwt.return_unit)));
    Alcotest_lwt.test_case
      "Can start a session with custom cookie key" `Slow (fun _lwtSwitch _ ->
      Cohttp_lwt_unix.Client.post
        (Uri.of_string "http://localhost:9993/no/middleware/login")
      >>= (fun (resp, _bod) ->
          let codeStr = Cohttp.Code.string_of_status resp.status in
          Alcotest.(check string "status" codeStr "200 OK");

          let headers = resp |> Cohttp.Response.headers in
          (match Cohttp.Header.get headers "Set-Cookie" with
          | Some cookie ->
            Alcotest.(
              check string "id" (String.sub cookie 0 10) "custom.sid")
          | None -> Alcotest.(check bool "fail" false true));
          Lwt.return_unit));
  ]) 