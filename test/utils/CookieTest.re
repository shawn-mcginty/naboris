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
];