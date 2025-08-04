type t = {
  status : int;
  headers : (string * string) list;
  closed : bool;
  exn : exn option;
}

let default () = {status = 200; headers = []; closed = false; exn = None}

let createResponse (res : t) =
  Httpaf.Response.create
    ~headers:(Httpaf.Headers.of_list res.headers)
    (Httpaf.Status.of_code res.status)

let addHeader (header : (string * string)) (res : t) =
  let (key, value) = header in
  {res with headers = (String.lowercase_ascii key, value) :: res.headers}

let addHeaderIfNone header res =
  let (key, _) = header in
  let existing = List.fold_left (fun exists h -> match exists with
    | true -> true
    | false ->
      let (k, _) = h in
      k = key) false res.headers in

  match existing with
    | true -> res
    | false -> addHeader header res

let status (status : int) (res : t) =
  {res with status}

let closeResponse res = {res with closed = true}

let addDateHeader res =
  let now = Unix.time () |> DateUtils.formatForHeaders in
  addHeaderIfNone ("Date", now) res

let addEtagHeader entity req res = match Req.responseEtag req with
  | None -> res
  | Some `Weak -> addHeaderIfNone ("Etag", Etag.weakFromString entity) res
  | Some `Strong -> addHeaderIfNone ("Etag", Etag.fromString entity) res

let raw (req : 'a Req.t) (body : string) (res : t) =
  let resWithHeaders = addHeaderIfNone ("Content-length", String.length body |> string_of_int) res
    |> addHeaderIfNone ("Connection", "keep-alive")
    |> addDateHeader
    |> addEtagHeader body req in
  let response = createResponse resWithHeaders in
  let requestDescriptor = Req.reqd req in

  let responseBody =
    Httpaf.Reqd.respond_with_streaming requestDescriptor response in
  Httpaf.Body.write_string responseBody body;
  Httpaf.Body.close_writer responseBody;
  Lwt.return (closeResponse resWithHeaders)

let text (req : 'a Req.t) (body : string) (res : t) = addHeader ("Content-Type", "text/plain") res
  |> raw req body

let json (req : 'a Req.t) (body : string) (res : t) = addHeader ("Content-Type", "application/json") res
  |> raw req body

let html (req : 'a Req.t) (htmlBody : string) (res : t) = addHeader ("Content-Type", "text/html") res
  |> raw req htmlBody

let streamFileContentsToBody fullFilePath responseBody =
  let readOnlyFlags = [Unix.O_RDONLY] in
  let readOnlyPerm = 0o444 in
  let%lwt fd = Lwt_unix.openfile fullFilePath readOnlyFlags readOnlyPerm in
  let channel = Lwt_io.of_fd fd ~mode:Lwt_io.Input in
  let bufferSize = Lwt_io.default_buffer_size () in
  let rec pipeBody ~count ch body =
    let%lwt chunk = Lwt_io.read ~count ch in
    Httpaf.Body.write_string body chunk;
    if String.length chunk < count then Lwt.return_unit else pipeBody ~count ch body
  in

  Lwt.finalize
    (fun () -> pipeBody ~count:bufferSize channel responseBody)
    (fun () ->
      Httpaf.Body.close_writer responseBody;
      Lwt_io.close channel)

let addCacheControl req res = match Req.staticCacheControl req with
  | None -> res
  | Some cacheControl -> addHeaderIfNone ("Cache-Control", cacheControl) res

let addLastModified req (stats : Unix.stats) res =
  let modifiedTime = DateUtils.formatForHeaders stats.st_mtime in

  match Req.staticLastModified req with
    | true -> addHeaderIfNone ("Last-Modified", modifiedTime) res
    | false -> res

let addFileEtagHeaders req fullFilePath res = match Req.responseEtag req with
  | None -> Lwt.return res
  | Some `Weak ->
    let%lwt etag = Etag.weakFromPath fullFilePath in
    addHeaderIfNone ("Etag", etag) res |> Lwt.return
  | Some `Strong ->
    let%lwt etag = Etag.fromFilePath fullFilePath in
    addHeaderIfNone ("Etag", etag) res |> Lwt.return

let addStaticHeaders req fullFilePath (stats : Unix.stats) res =
  let size = stats.st_size in

  addHeaderIfNone ("Content-Type", MimeTypes.getMimeType fullFilePath) res
    |> addHeaderIfNone ("Content-Length", string_of_int size)
    |> addCacheControl req
    |> addLastModified req stats
    |> addDateHeader
    |> addFileEtagHeaders req fullFilePath

let static basePath pathList (req : 'a Req.t) res =
  let fullFilePath = Static.getFilePath basePath pathList in
  let%lwt exists = Lwt_unix.file_exists fullFilePath in
  match exists with
    | true ->
      let%lwt stats = Lwt_unix.stat fullFilePath in
      let%lwt resWithHeaders = addStaticHeaders req fullFilePath stats res in

      let response = createResponse resWithHeaders in
      let requestDescriptor = Req.reqd req in
      let responseBody =
        Httpaf.Reqd.respond_with_streaming requestDescriptor response in
      let%lwt () = streamFileContentsToBody fullFilePath responseBody in
      Lwt.return @@ closeResponse @@ resWithHeaders
    | _ ->
      let resWithHeaders =
        status 404 res |> addHeader ("Content-Length", "9") |> addHeader ("Connection", "keep-alive") in
      let response = createResponse resWithHeaders in
      let responseBody =
        Httpaf.Reqd.respond_with_streaming (Req.reqd req) response in
      Httpaf.Body.write_string responseBody "Not found";
      Httpaf.Body.close_writer responseBody;
      Lwt.return @@ closeResponse @@ resWithHeaders

let setSessionCookies newSessionId sessionIdKey maxAge res =
  let setCookieKey = "Set-Cookie" in
  let maxAgeStr = string_of_int maxAge in

  addHeader
    (setCookieKey,
     sessionIdKey ^ "=" ^ newSessionId ^ "; Max-Age=" ^ maxAgeStr ^ ";")
    res

let redirect path req res =
  status 302 res |> addHeader ("Location", path) |> text req "Found"

let reportError exn (req : 'a Req.t) res =
  Httpaf.Reqd.report_exn (Req.reqd req) exn;
  Lwt.return @@ closeResponse {res with exn = Some exn}

let writeChannel (req : 'a Req.t) res =
  let reqd = Req.reqd req in
  let resWithHeaders = addHeader ("Transfer-encoding", "chunked") res
    |> addHeader ("Connection", "keep-alive") in

  let responseBody = resWithHeaders
    |> createResponse
    |> Httpaf.Reqd.respond_with_streaming ~flush_headers_immediately:true reqd in

  let onWrite bytes off len =
    Httpaf.Body.write_bigstring ~off ~len responseBody bytes;
    Lwt.return len
  in

  let (respPromise, respResolver) = Lwt.task () in

  let close () =
    Httpaf.Body.close_writer responseBody;
    Lwt.wakeup respResolver (closeResponse resWithHeaders);
    Lwt.return_unit
  in

  (Lwt_io.make
    ~close
    ~mode:Output
    onWrite, respPromise) 