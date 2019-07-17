let rec getSessionId = cookieStr => {
  print_endline("DEBUG: " ++ cookieStr);
  let sessionKey = "nab.sid=";
  let cookieLength = String.length(cookieStr);
  let keyLength = String.length(sessionKey);
  let startOfString = 0;

  switch (String.index_opt(cookieStr, sessionKey.[startOfString])) {
  | None => None
  | Some(i) =>
    let highestLen = keyLength + i;
    if (String.length(cookieStr) < highestLen) {
      None;
    } else if (String.sub(cookieStr, i, keyLength) == sessionKey) {
      let partialCookie =
        String.sub(cookieStr, highestLen, cookieLength - highestLen);
      switch (String.index_opt(partialCookie, ';')) {
      | None => None
      | Some(endOfCookie) =>
        Some(String.sub(partialCookie, startOfString, endOfCookie))
      };
    } else {
      getSessionId(String.sub(cookieStr, i, cookieLength - i));
    };
  };
};

let sessionIdOfReq = req => {
  print_endline("\nDEBUG:    " ++ "Naboris - Cookie - sessionIdOfReq start");
  switch (Req.getHeader("Cookie", req)) {
  | None =>
    print_endline(
      "\nDEBUG:    " ++ "Naboris - Cookie - sessionIdOfReq no cookie header",
    );
    None;
  | Some(header) =>
    print_endline(
      "\nDEBUG:    "
      ++ "Naboris - Cookie - sessionIdOfReq some header get sessionId",
    );
    getSessionId(header);
  };
};