let rec getSessionId = (sidKey, cookieStr) => {
  let sessionKey = sidKey ++ "=";
  let cookieLength = String.length(cookieStr);
  let keyLength = String.length(sessionKey);
  let startOfString = 0;

  switch (String.index_opt(cookieStr, sessionKey.[startOfString])) {
  | None => None
  | Some(i) =>
    let highestLen = keyLength + i;
    if (cookieLength < highestLen) {
      None;
    } else if (String.sub(cookieStr, i, keyLength) == sessionKey) {
      let partialCookie =
        String.sub(cookieStr, highestLen, cookieLength - highestLen);

      switch (String.index_opt(partialCookie, ';')) {
      | None => Some(partialCookie)
      | Some(endOfCookie) =>
        Some(String.sub(partialCookie, startOfString, endOfCookie))
      };
    } else {
      getSessionId(sidKey, String.sub(cookieStr, i + 1, cookieLength - (i + 1)));
    };
  };
};

let sessionIdOfReq = req => {
  switch (Req.getHeader("Cookie", req)) {
  | None => None
  | Some(header) => getSessionId(Req.sidKey(req), header)
  };
};