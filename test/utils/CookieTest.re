open OUnit2;

let testSuite = () => [
  "utils/Cookie.getSessionId returns the id from the ugly string"
  >:: (
    _ => {
      let expectedSid = "this-is-my-big-ass-session-id-woohoo";
      let cookieStr =
        "this=ugly; super=ugly; nab.sid=" ++ expectedSid ++ "; also=here;";
      switch (Naboris.Cookie.getSessionId(cookieStr)) {
      | None => assert_equal(false, true)
      | Some(actualSid) => assert_equal(actualSid, expectedSid)
      };
    }
  ),
  "utils/Cookie.getSessionId fix recursion bug"
  >:: (
    _ => {
      let cookieStr = "nnect.sid=s%3AadVKe5fVEcZVq4X5ZUrMen2U88jmjy4f.LOwere3akcgCno7WDqinHgL%2BXWXVp2SgbHZzv7%2Btbt4";
      let maybeCookie = Naboris.Cookie.getSessionId(cookieStr);
      assert_equal(None, maybeCookie);
    }
  ),
  "utils/Cookie.getSessionId fix big cookie str"
  >:: (
    _ => {
      let expectedSid = "67f67df4c5d9711ef89bbf8b509d49e2cc1ce51e3d95c90d45485a7b3cf40ca4ec9cbbceb0ca6ad844ec4a4779fd9981b130c40f81646f2ef286749c7184e66f";
      let cookieStr = "_ga=GA1.1.1652070095.1563853850; express.sid=s%3AhSEgvCCmOADa-0Flv4ulT1FltA8TzHeq.G1UoU2xXC8X8wkEO5I0J%2BhE3NCjUoggAlGnz0jA1%2B2w; _gid=GA1.1.1409339010.1564626384; connect.sid=s%3AClROuVLX_Dalzkmf0D4d0Xath-HHG16M.8zaxTWykLFnypEw%2BCAIZRTPJR7IKBDUcAamWUch4Czk; nab.sid=67f67df4c5d9711ef89bbf8b509d49e2cc1ce51e3d95c90d45485a7b3cf40ca4ec9cbbceb0ca6ad844ec4a4779fd9981b130c40f81646f2ef286749c7184e66f";
      switch (Naboris.Cookie.getSessionId(cookieStr)) {
      | None => assert_equal(false, true)
      | Some(actualSid) => assert_equal(actualSid, expectedSid)
      };
    }
  ),
];