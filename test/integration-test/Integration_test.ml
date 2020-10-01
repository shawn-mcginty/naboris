exception SomebodyGoofed of string

let check_status_and_body uri_str expected_status expected_body =
  let%lwt resp, bod = Cohttp_lwt_unix.Client.get (Uri.of_string uri_str) in
  let code_str = Cohttp.Code.string_of_status resp.status in
  let () = Alcotest.(check string "status" code_str expected_status) in
  let%lwt body_str = Cohttp_lwt.Body.to_string bod in
  let () = Alcotest.(check string "body" body_str expected_body) in
  Lwt.return_unit

let echo_query_query req res query =
  let maybe_str1 = Naboris.Query.QueryMap.find_opt "q" query in
  let maybe_str2 = Naboris.Query.QueryMap.find_opt "q2" query in
  let maybe_str3 = Naboris.Query.QueryMap.find_opt "q3" query in

  let vals = [ maybe_str1; maybe_str2; maybe_str3 ] in

  match vals with
  | [ Some (str1 :: _); Some (str2 :: _); Some (str3 :: _) ] ->
      Naboris.Res.status 200 res
      |> Naboris.Res.html req (str1 ^ "\n" ^ str2 ^ "\n" ^ str3)
  | _ -> Naboris.Res.status 500 res |> Naboris.Res.html req "fail"

let session_config : TestSession.t Naboris.SessionConfig.t =
  {
    sid_key = "nab.sid";
    secret = "Keeep it secret, keep it safe!";
    max_age = 3600;
    get_session =
      (fun session_id ->
        let user_data = TestSession.{ username = "realsessionuser" } in
        match session_id with
        | Some sid -> Lwt.return (Some (Naboris.Session.make sid user_data))
        | _ -> Lwt.return None);
  }

let start_servers lwt_switch =
  let ssp1, ssr1 = Lwt.task () in
  let ssp2, ssr2 = Lwt.task () in
  let ssp3, ssr3 = Lwt.task () in

  let () =
    Lwt_switch.add_hook (Some lwt_switch) (fun () ->
        let () = Lwt.cancel ssp1 in
        let () = Lwt.cancel ssp2 in
        Lwt.return_unit)
  in

  let test_server_config : TestSession.t Naboris.ServerConfig.t =
    Naboris.ServerConfig.make ()
    |> Naboris.ServerConfig.set_on_listen (fun () -> Lwt.wakeup_later ssr1 ())
    |> Naboris.ServerConfig.set_session_config session_config.get_session
    |> Naboris.ServerConfig.add_static_middleware [ "static" ]
         (Sys.getenv "cur__root" ^ "/test/integration-test/test_assets")
    |> Naboris.ServerConfig.set_error_handler (fun error _route ->
           match error with
           | SomebodyGoofed _ -> Lwt.return ([], "Dude, somebody goofed")
           | _ -> Lwt.return ([], "else"))
    |> Naboris.ServerConfig.set_request_handler (fun route req res ->
           match (Naboris.Route.meth route, Naboris.Route.path route) with
           | GET, [ "echo"; "pre-existing-route" ] ->
               Naboris.Res.status 200 res
               |> Naboris.Res.html req
                    "This route should take priority in the matcher."
           | GET, [ "html" ] ->
               Naboris.Res.status 200 res
               |> Naboris.Res.html req
                    "<!doctype html><html><body>You made it.</body></html>"
           | GET, [ "user"; _user_id; "item"; _item_id ] ->
               Naboris.Res.status 200 res
               |> Naboris.Res.html req
                    "<!doctype html><html><body>You want some user id and \
                     item</body></html>"
           | GET, [ "echo-query"; "query" ] ->
               echo_query_query req res (Naboris.Route.query route)
           | GET, [ "echo"; str ] ->
               Naboris.Res.status 200 res |> Naboris.Res.html req str
           | GET, [ "echo"; str1; "multi"; str2 ] ->
               Naboris.Res.status 200 res
               |> Naboris.Res.html req (str1 ^ "\n" ^ str2)
           | POST, [ "echo" ] ->
               let%lwt body_str = Naboris.Req.get_body req in
               Naboris.Res.status 200 res |> Naboris.Res.html req body_str
           | POST, [ "login" ] ->
               let req2, res2, _sid =
                 Naboris.SessionManager.start_session req res
                   TestSession.{ username = "realsessionuser" }
               in
               Naboris.Res.status 200 res2 |> Naboris.Res.text req2 "OK"
           | GET, [ "logout" ] ->
               Naboris.SessionManager.remove_session req res
               |> Naboris.Res.status 200 |> Naboris.Res.text req "OK"
           | GET, [ "who-am-i" ] -> (
               match Naboris.Req.get_session_data req with
               | None ->
                   Naboris.Res.status 404 res
                   |> Naboris.Res.text req "Not found"
               | Some user_data ->
                   Naboris.Res.status 200 res
                   |> Naboris.Res.text req user_data.username )
           | GET, [ "redir-launch" ] ->
               Naboris.Res.redirect "/redir-landing" req res
           | GET, [ "redir-landing" ] ->
               Naboris.Res.status 200 res
               |> Naboris.Res.text req "You have landed"
           | GET, [ "test-json" ] ->
               Naboris.Res.status 200 res
               |> Naboris.Res.json req "{\"test\": \"foo\"}"
           | GET, [ "test-raw" ] ->
               Naboris.Res.status 200 res
               |> Naboris.Res.add_header ("Content-Type", "application/xml")
               |> Naboris.Res.raw req "<xml></xml>"
           | GET, [ "test-streaming" ] ->
               let ch, return =
                 Naboris.Res.add_header ("Content-Type", "text/html") res
                 |> Naboris.Res.write_channel req
               in
               let _ =
                 Lwt.async (fun () ->
                     let%lwt _ =
                       Lwt_io.write ch "<html><head><title>Foo</title></head>"
                     in
                     let%lwt _ = Lwt_io.flush ch in
                     let%lwt _ = Lwt_io.write ch "<body>Some data" in
                     let%lwt _ =
                       Lwt_io.write ch ". And more data.</body></html>"
                     in
                     Lwt_io.close ch)
               in
               return
           | GET, [ "error"; "boys" ] ->
               Naboris.Res.report_error (SomebodyGoofed "Problems") req res
           | _ ->
               Naboris.Res.status 404 res
               |> Naboris.Res.html req
                    "<!doctype html><html><body>Page not found</body></html>")
  in

  let test_server_config2 : TestSession.t Naboris.ServerConfig.t =
    Naboris.ServerConfig.make ()
    |> Naboris.ServerConfig.set_on_listen (fun () -> Lwt.wakeup_later ssr2 ())
    |> Naboris.ServerConfig.set_request_handler (fun route req res ->
           match (Naboris.Route.meth route, Naboris.Route.path route) with
           | _ ->
               Naboris.Res.status 404 res
               |> Naboris.Res.html req
                    "<!doctype html><html><body>Page not found</body></html>")
  in

  let test_server_config3 : TestSession.t Naboris.ServerConfig.t =
    Naboris.ServerConfig.make ()
    |> Naboris.ServerConfig.set_session_config ~sid_key:"custom.sid"
         session_config.get_session
    |> Naboris.ServerConfig.add_middleware (fun next route req res ->
           match Naboris.Route.path route with
           | [ "middleware"; "one"; _ ] ->
               res |> Naboris.Res.status 200
               |> Naboris.Res.text req "middleware 1"
           | _ -> next route req res)
    |> Naboris.ServerConfig.add_middleware (fun next route req res ->
           match Naboris.Route.path route with
           | [ "middleware"; "one"; "never" ] ->
               res |> Naboris.Res.status 200
               |> Naboris.Res.text req "this should never happen"
           | [ "middleware"; "two" ] ->
               res |> Naboris.Res.status 200
               |> Naboris.Res.text req "middleware 2"
           | _ -> next route req res)
    |> Naboris.ServerConfig.set_on_listen (fun () -> Lwt.wakeup_later ssr3 ())
    |> Naboris.ServerConfig.set_request_handler (fun route req res ->
           match Naboris.Route.path route with
           | [ "no"; "middleware" ] ->
               res |> Naboris.Res.status 200
               |> Naboris.Res.text req "Regular router"
           | [ "no"; "middleware"; "login" ] ->
               let req2, res2, _sid =
                 Naboris.SessionManager.start_session req res
                   TestSession.{ username = "realsessionuser" }
               in
               Naboris.Res.status 200 res2 |> Naboris.Res.text req2 "OK"
           | _ ->
               res |> Naboris.Res.status 404
               |> Naboris.Res.text req "Resource not found.")
  in

  let _ = Naboris.listen_and_wait_forever 9991 test_server_config in
  let%lwt _ = ssp1 in
  let%lwt _ = Lwt_unix.sleep 1.0 in
  let _ = Naboris.listen_and_wait_forever 9992 test_server_config2 in
  let%lwt _ = ssp2 in
  let%lwt _ = Lwt_unix.sleep 1.0 in
  let _ = Naboris.listen_and_wait_forever 9993 test_server_config3 in
  ssp3

let test_suite () =
  ( "Integration Test",
    [
      Alcotest_lwt.test_case "Start servers" `Slow (fun lwt_switch _ ->
          start_servers lwt_switch);
      Alcotest_lwt.test_case
        "GET \"/this-should-never-exist\" returns a 404 by default" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, _bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/this-should-never-exist")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "404 Not Found") in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Get\"/this-should-never-exist\" returns a 404 by default" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, _bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9992/this-should-never-exist")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "404 Not Found") in
          Lwt.return_unit);
      Alcotest_lwt.test_case "Get \"/html\" returns a 200 and html document"
        `Slow (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/html")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () =
            Alcotest.(
              check string "html body" body_str
                "<!doctype html><html><body>You made it.</body></html>")
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Get \"/user/:userId/item/:itemId\" matches with integers" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/user/1/item/0")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () =
            Alcotest.(
              check string "body string" body_str
                "<!doctype html><html><body>You want some user id and \
                 item</body></html>")
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Get \"/user/:userId/item/:itemId\" matches with uuids" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string
                 "http://localhost:9991/user/bfdb66ad-f974-4293-acf9-dfda390abdc4/item/8f146ab9-94d1-46a9-bd0f-2079e22314f4")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () =
            Alcotest.(
              check string "html body" body_str
                "<!doctype html><html><body>You want some user id and \
                 item</body></html>")
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Get \"/echo/:str\" matches and extracts param properly" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/echo/test 1")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let _ = Alcotest.(check string "status" code_str "200 OK") in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let _ = Alcotest.(check string "body" body_str "test 1") in
          Lwt.return_unit);
      Alcotest_lwt.test_case "Get sets headers properly" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, _bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/echo/test 1")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let date_header =
            Cohttp.Header.get (Cohttp.Response.headers resp) "date"
          in
          let has_date = match date_header with None -> false | _ -> true in
          let etag = Cohttp.Header.get (Cohttp.Response.headers resp) "etag" in
          let has_etag = match etag with None -> false | _ -> true in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let () = Alcotest.(check bool "has date header" has_date true) in
          let () = Alcotest.(check bool "has etag header" has_etag true) in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Get \"/echo/:str1/multi/:str2\" matches and extracts param(s) properly"
        `Slow (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/echo/test 11/multi/test 2")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () = Alcotest.(check string "body" body_str "test 11\ntest 2") in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Get \"/echo-query/query\" matches and extracts query params properly"
        `Slow (fun _lwt_switch _ ->
          let%lwt resp, body =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string
                 "http://localhost:9991/echo-query/query?q=foo&q2=bar&q3=baz")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let%lwt body_str = Cohttp_lwt.Body.to_string body in
          let () = Alcotest.(check string "body" body_str "foo\nbar\nbaz") in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Get \"/echo/pre-existing-route\" routes properly based on top to \
         bottom priority"
        `Slow (fun _lwt_switch _ ->
          check_status_and_body "http://localhost:9991/echo/pre-existing-route"
            "200 OK" "This route should take priority in the matcher.");
      Alcotest_lwt.test_case "Post \"/echo\" gets post body ast plain/text"
        `Slow (fun _lwt_switch _ ->
          let expected_body =
            "This is the string I expect to see from the body."
          in
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.post
              ~body:(Cohttp_lwt.Body.of_string expected_body)
              (Uri.of_string "http://localhost:9991/echo")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () = Alcotest.(check string "body" body_str expected_body) in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Get \"/static/:file_path\" matches and extracts query params properly"
        `Slow (fun _lwt_switch _ ->
          check_status_and_body
            "http://localhost:9991/static/text/text_file.txt" "200 OK"
            "Hello world!");
      Alcotest_lwt.test_case "Get static files sends correct headers" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, _bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/static/text/text_file.txt")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let headers = Cohttp.Response.headers resp in
          let cache_control = Cohttp.Header.get headers "cache-control" in
          let last_modified = Cohttp.Header.get headers "last-modified" in
          let has_last_modified = Option.is_some last_modified in
          let etag = Cohttp.Header.get headers "etag" in
          let has_etag = Option.is_some etag in
          let () =
            Alcotest.(
              check (option string) "cache-control" cache_control
                (Some "public, max-age=0"))
          in
          let () =
            Alcotest.(check bool "has last-modified" has_last_modified true)
          in
          let () = Alcotest.(check bool "has etag" has_etag true) in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Get \"/static/:file_path\" gets files bigger than 512B" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/static/text/1024.txt")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () =
            Alcotest.(check int "length" (String.length body_str) 1024)
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Get \"/static/:file_path\" returns 404 when file not found" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, _bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string
                 "http://localhost:9991/static/no/such/path/I_DO_NOT_EXIST")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "404 Not Found") in
          Lwt.return_unit);
      Alcotest_lwt.test_case "Can start a session" `Slow (fun _lwt_switch _ ->
          let%lwt resp, _bod =
            Cohttp_lwt_unix.Client.post
              (Uri.of_string "http://localhost:9991/login")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let headers = Cohttp.Response.headers resp in
          let cookie =
            Option.value ~default:"NOT.sid"
              (Cohttp.Header.get headers "Set-Cookie")
          in
          let () =
            Alcotest.(check string "id" (String.sub cookie 0 7) "nab.sid")
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case "Handle no session" `Slow (fun _lwt_switch _ ->
          let%lwt resp, _bod =
            Cohttp_lwt_unix.Client.post
              (Uri.of_string "http://localhost:9991/who-am-i")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "404 Not Found") in
          Lwt.return_unit);
      Alcotest_lwt.test_case "Access session data across multiple requests"
        `Slow (fun _lwt_switch _ ->
          let%lwt resp, _bod =
            Cohttp_lwt_unix.Client.post
              (Uri.of_string "http://localhost:9991/login")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let headers = Cohttp.Response.headers resp in
          match Cohttp.Header.get headers "Set-Cookie" with
          | None ->
              let () = Alcotest.(check bool "failed" false true) in
              Lwt.return_unit
          | Some raw_cookie ->
              let cookie =
                "_ga=GA1.1.1652070095.1563853850; \
                 express.sid=s%3AhSEgvCCmOADa-0Flv4ulT1FltA8TzHeq.G1UoU2xXC8X8wkEO5I0J%2BhE3NCjUoggAlGnz0jA1%2B2w; \
                 _gid=GA1.1.1409339010.1564626384; \
                 connect.sid=s%3AClROuVLX_Dalzkmf0D4d0Xath-HHG16M.8zaxTWykLFnypEw%2BCAIZRTPJR7IKBDUcAamWUch4Czk; "
                ^ raw_cookie
              in
              let headers2 = Cohttp.Header.init_with "Cookie" cookie in
              let%lwt resp2, bod =
                Cohttp_lwt_unix.Client.get ~headers:headers2
                  (Uri.of_string "http://localhost:9991/who-am-i")
              in
              let code_str = Cohttp.Code.string_of_status resp2.status in
              let () = Alcotest.(check string "status" code_str "200 OK") in
              let%lwt body_str = Cohttp_lwt.Body.to_string bod in
              let () =
                Alcotest.(check string "body" body_str "realsessionuser")
              in
              Lwt.return_unit);
      Alcotest_lwt.test_case "Can remove session cookies" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, _bod =
            Cohttp_lwt_unix.Client.post
              (Uri.of_string "http://localhost:9991/login")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let headers = Cohttp.Response.headers resp in
          match Cohttp.Header.get headers "Set-Cookie" with
          | None ->
              let () = Alcotest.(check bool "failed" false true) in
              Lwt.return_unit
          | Some _ ->
              let cookie =
                "_ga=GA1.1.1652070095.1563853850; \
                 express.sid=s%3AhSEgvCCmOADa-0Flv4ulT1FltA8TzHeq.G1UoU2xXC8X8wkEO5I0J%2BhE3NCjUoggAlGnz0jA1%2B2w; \
                 _gid=GA1.1.1409339010.1564626384; \
                 connect.sid=s%3AClROuVLX_Dalzkmf0D4d0Xath-HHG16M.8zaxTWykLFnypEw%2BCAIZRTPJR7IKBDUcAamWUch4Czk; \
                 nab.sid=67f67df4c5d9711ef89bbf8b509d49e2cc1ce51e3d95c90d45485a7b3cf40ca4ec9cbbceb0ca6ad844ec4a4779fd9981b130c40f81646f2ef286749c7184e66f"
              in
              let headers2 = Cohttp.Header.init_with "Cookie" cookie in
              let%lwt resp2, _bod =
                Cohttp_lwt_unix.Client.get ~headers:headers2
                  (Uri.of_string "http://localhost:9991/logout")
              in
              let code_str2 = Cohttp.Code.string_of_status resp2.status in
              let () = Alcotest.(check string "status" code_str2 "200 OK") in
              let logout_headers = Cohttp.Response.headers resp2 in
              let set_cookie_header =
                Cohttp.Header.get logout_headers "Set-Cookie"
                |> Option.value ~default:""
              in
              let () =
                Alcotest.(
                  check string "set cookie" set_cookie_header
                    "nab.sid=; Max-Age=0;")
              in
              Lwt.return_unit);
      Alcotest_lwt.test_case "Redirects properly" `Slow (fun _lwt_switch _ ->
          let%lwt resp, _bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/redir-launch")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "302 Found") in
          let () =
            Alcotest.(
              check (option string) "redirect"
                (Cohttp.Header.get resp.headers "Location")
                (Some "/redir-landing"))
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case "Report error returns 500" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/error/boys")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () =
            Alcotest.(
              check string "status" code_str "500 Internal Server Error")
          in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () =
            Alcotest.(check string "body" body_str "Dude, somebody goofed")
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case "Get \"/json-test\" sends json header" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/test-json")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let () =
            Alcotest.(
              check (option string) "content type"
                (Cohttp.Header.get resp.headers "Content-type")
                (Some "application/json"))
          in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () =
            Alcotest.(check string "body" body_str "{\"test\": \"foo\"}")
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case "Get \"/test-raw\" sends xml header" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/test-raw")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let () =
            Alcotest.(
              check (option string) "content type"
                (Cohttp.Header.get resp.headers "Content-type")
                (Some "application/xml"))
          in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () = Alcotest.(check string "body" body_str "<xml></xml>") in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Get \"/test-streaming\" sends chunked header and data" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.get
              (Uri.of_string "http://localhost:9991/test-streaming")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let () =
            Alcotest.(
              check (option string) "transfer encoding"
                (Cohttp.Header.get resp.headers "transfer-encoding")
                (Some "chunked"))
          in
          let () =
            Alcotest.(
              check (option string) "no content length"
                (Cohttp.Header.get resp.headers "content-length")
                None)
          in
          let () =
            Alcotest.(
              check (option string) "keep alive"
                (Cohttp.Header.get resp.headers "connection")
                (Some "keep-alive"))
          in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () =
            Alcotest.(
              check string "body" body_str
                "<html><head><title>Foo</title></head><body>Some data. And \
                 more data.</body></html>")
          in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Middleware - Get \"/middleware/one/never\" should be served by the \
         first middleware"
        `Slow (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.post
              (Uri.of_string "http://localhost:9993/middleware/one/never")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let () =
            Alcotest.(
              check (option string) "content type"
                (Cohttp.Header.get resp.headers "Content-Type")
                (Some "text/plain"))
          in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () = Alcotest.(check string "body" body_str "middleware 1") in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Middleware - Get \"/middleware/two\" should be served by the second \
         middleware"
        `Slow (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.post
              (Uri.of_string "http://localhost:9993/middleware/two")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let () =
            Alcotest.(
              check (option string) "content type"
                (Cohttp.Header.get resp.headers "Content-Type")
                (Some "text/plain"))
          in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () = Alcotest.(check string "body" body_str "middleware 2") in
          Lwt.return_unit);
      Alcotest_lwt.test_case
        "Middleware - Get \"/no/middleware\" should be served by the route \
         handler"
        `Slow (fun _lwt_switch _ ->
          let%lwt resp, bod =
            Cohttp_lwt_unix.Client.post
              (Uri.of_string "http://localhost:9993/no/middleware")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let () =
            Alcotest.(
              check (option string) "content type"
                (Cohttp.Header.get resp.headers "Content-Type")
                (Some "text/plain"))
          in
          let%lwt body_str = Cohttp_lwt.Body.to_string bod in
          let () = Alcotest.(check string "body" body_str "Regular router") in
          Lwt.return_unit);
      Alcotest_lwt.test_case "Can start a session with custom cookie key" `Slow
        (fun _lwt_switch _ ->
          let%lwt resp, _bod =
            Cohttp_lwt_unix.Client.post
              (Uri.of_string "http://localhost:9993/no/middleware/login")
          in
          let code_str = Cohttp.Code.string_of_status resp.status in
          let () = Alcotest.(check string "status" code_str "200 OK") in
          let () =
            match Cohttp.Header.get resp.headers "Set-Cookie" with
            | Some cookie ->
                Alcotest.(
                  check string "id" (String.sub cookie 0 10) "custom.sid")
            | None -> Alcotest.(check bool "fail" false true)
          in
          Lwt.return_unit);
    ] )
