let rec getSessionId sidKey cookieStr =
  let sessionKey = sidKey ^ "=" in
  let cookieLength = String.length cookieStr in
  let keyLength = String.length sessionKey in
  let startOfString = 0 in

  match String.index_opt cookieStr sessionKey.[startOfString] with
  | None -> None
  | Some i ->
    let highestLen = keyLength + i in
    if cookieLength < highestLen then
      None
    else if String.sub cookieStr i keyLength = sessionKey then
      let partialCookie =
        String.sub cookieStr highestLen (cookieLength - highestLen) in

      (match String.index_opt partialCookie ';' with
      | None -> Some partialCookie
      | Some endOfCookie ->
        Some (String.sub partialCookie startOfString endOfCookie))
    else
      getSessionId sidKey (String.sub cookieStr (i + 1) (cookieLength - (i + 1)))

let sessionIdOfReq req =
  match Req.getHeader "Cookie" req with
  | None -> None
  | Some header -> getSessionId (Req.sidKey req) header 