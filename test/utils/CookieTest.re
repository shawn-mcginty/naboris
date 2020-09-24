let testSuite = () => (
  "utils_Cookie",
  [
    Alcotest_lwt.test_case(
      "get_session_id returns the id from the ugly string",
      `Quick,
      (_lwtSwitch, _) => {
        let expectedSid = "this-is-my-big-ass-session-id-woohoo";
        let cookieStr =
          "this=ugly; super=ugly; nab.sid=" ++ expectedSid ++ "; also=here;";
        Alcotest.(
          check(
            option(string),
            "same sid",
            Naboris.Cookie.get_session_id("nab.sid", cookieStr),
            Some(expectedSid),
          )
        );
        Lwt.return_unit;
      },
    ),
    Alcotest_lwt.test_case(
      "get_session_id fix recursion bug",
      `Quick,
      (_lwtSwitch, _) => {
        let cookieStr = "nnect.sid=s%3AadVKe5fVEcZVq4X5ZUrMen2U88jmjy4f.LOwere3akcgCno7WDqinHgL%2BXWXVp2SgbHZzv7%2Btbt4";
        let maybeCookie = Naboris.Cookie.get_session_id("nab.sid", cookieStr);
        Alcotest.(
          check(option(string), "no matching cookie", None, maybeCookie)
        );
        Lwt.return_unit;
      },
    ),
    Alcotest_lwt.test_case(
      "get_session_id fix big cookie str",
      `Quick,
      (_lwtSwitch, _) => {
        let expectedSid = "67f67df4c5d9711ef89bbf8b509d49e2cc1ce51e3d95c90d45485a7b3cf40ca4ec9cbbceb0ca6ad844ec4a4779fd9981b130c40f81646f2ef286749c7184e66f";
        let cookieStr = "_ga=GA1.1.1652070095.1563853850; express.sid=s%3AhSEgvCCmOADa-0Flv4ulT1FltA8TzHeq.G1UoU2xXC8X8wkEO5I0J%2BhE3NCjUoggAlGnz0jA1%2B2w; _gid=GA1.1.1409339010.1564626384; connect.sid=s%3AClROuVLX_Dalzkmf0D4d0Xath-HHG16M.8zaxTWykLFnypEw%2BCAIZRTPJR7IKBDUcAamWUch4Czk; nab.sid=67f67df4c5d9711ef89bbf8b509d49e2cc1ce51e3d95c90d45485a7b3cf40ca4ec9cbbceb0ca6ad844ec4a4779fd9981b130c40f81646f2ef286749c7184e66f";
        Alcotest.(
          check(
            option(string),
            "same sid",
            Naboris.Cookie.get_session_id("nab.sid", cookieStr),
            Some(expectedSid),
          )
        );
        Lwt.return_unit;
      },
    ),
    Alcotest_lwt.test_case(
      "get_session_id returns none when cookie str is part of the key",
      `Quick,
      (_lwtSwitch, _) => {
        let cookieStr = "nib";
        Alcotest.(
          check(
            option(string),
            "empty",
            Naboris.Cookie.get_session_id("nab.sid", cookieStr),
            None,
          )
        );
        Lwt.return_unit;
      },
    ),
  ],
);