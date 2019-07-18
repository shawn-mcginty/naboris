open OUnit;

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
];