type t = {
  status: int,
  headers: list((string, string)),
  closed: bool,
  exn: option(exn),
};

let default = () => {status: 200, headers: [], closed: false, exn: None};

let createResponse = (res: t) => {
  Httpaf.Response.create(
    ~headers=Httpaf.Headers.of_list(res.headers),
    Httpaf.Status.of_code(res.status),
  );
};

let addHeader = (header: (string, string), res: t) => {
  let (key, value) = header;
  {...res, headers: [(String.lowercase_ascii(key), value), ...res.headers]};
};

let addHeaderIfNone = (header, res) => {
  let (key, _) = header;
  let existing = List.fold_left((exists, h) => switch(exists) {
    | true => true
    | false =>
      let (k, _) = h;
      k == key;
  }, false, res.headers);

  switch(existing) {
    | true => res
    | false => addHeader(header, res);
  };
};

let status = (status: int, res: t) => {
  {...res, status};
};

let closeResponse = (res) => { ...res, closed: true };

let addDateHeader = (res) => {
  let now = Unix.time() |> DateUtils.formatForHeaders;
  addHeaderIfNone(("Date", now), res);
};

let addEtagHeader = (entity, req, res) => switch (Req.responseEtag(req)) {
  | None => res
  | Some(`Weak) => addHeaderIfNone(("Etag", Etag.weakFromString(entity)), res)
  | Some(`Strong) => addHeaderIfNone(("Etag", Etag.fromString(entity)), res)
}

let raw = (req: Req.t('a), body: string, res: t) => {
  let resWithHeaders = addHeaderIfNone(("Content-length", String.length(body) |> string_of_int), res)
    |> addHeaderIfNone(("Connection", "keep-alive"))
    |> addDateHeader
    |> addEtagHeader(body, req);
  let response = createResponse(resWithHeaders);
  let requestDescriptor = Req.reqd(req);

  let responseBody =
    Httpaf.Reqd.respond_with_streaming(requestDescriptor, response);
  Httpaf.Body.write_string(responseBody, body);
  Httpaf.Body.close_writer(responseBody);
  Lwt.return(closeResponse(resWithHeaders));
};

let text = (req: Req.t('a), body: string, res: t) => addHeader(("Content-Type", "text/plain"), res)
  |> raw(req, body);

let json = (req: Req.t('a), body: string, res: t) => addHeader(("Content-Type", "application/json"), res)
  |> raw(req, body);

let html = (req: Req.t('a), htmlBody: string, res: t) => addHeader(("Content-Type", "text/html"), res)
  |> raw(req, htmlBody);

let streamFileContentsToBody = (fullFilePath, responseBody) => {
  let readOnlyFlags = [Unix.O_RDONLY];
  let readOnlyPerm = 444;
  let%lwt fd = Lwt_unix.openfile(fullFilePath, readOnlyFlags, readOnlyPerm);
  let channel = Lwt_io.of_fd(fd, ~mode=Lwt_io.Input);
  let bufferSize = Lwt_io.default_buffer_size();
  let rec pipeBody = (~count, ch, body) => {
    let%lwt chunk = Lwt_io.read(~count, ch);
    Httpaf.Body.write_string(body, chunk);
    String.length(chunk) < count ? { Lwt.return_unit; } : pipeBody(~count, ch, body);
  };

  Lwt.finalize(
    () => pipeBody(~count=bufferSize, channel, responseBody),
    () => {
      Httpaf.Body.close_writer(responseBody);
      Lwt_io.close(channel);
    },
  );
};

let addCacheControl = (req, res) => switch(Req.staticCacheControl(req)) {
  | None => res
  | Some(cacheControl) => addHeaderIfNone(("Cache-Control", cacheControl), res)
};

let addLastModified = (req, stats: Unix.stats, res) => {
  let modifiedTime = DateUtils.formatForHeaders(stats.st_mtime);

  switch(Req.staticLastModified(req)) {
    | true => addHeaderIfNone(("Last-Modified", modifiedTime), res)
    | false => res
  };
}

let addFileEtagHeaders = (req, fullFilePath, res) => switch(Req.responseEtag(req)) {
  | None => Lwt.return(res)
  | Some(`Weak) =>
    let%lwt etag = Etag.weakFromPath(fullFilePath);
    addHeaderIfNone(("Etag", etag), res) |> Lwt.return;
  | Some(`Strong) =>
    let%lwt etag = Etag.fromFilePath(fullFilePath);
    addHeaderIfNone(("Etag", etag), res) |> Lwt.return;
};

let addStaticHeaders = (req, fullFilePath, stats: Unix.stats, res) => {
  let size = stats.st_size;

  addHeaderIfNone(("Content-Type", MimeTypes.getMimeType(fullFilePath)), res)
    |> addHeaderIfNone(("Content-Length", string_of_int(size)))
    |> addCacheControl(req)
    |> addLastModified(req, stats)
    |> addDateHeader
    |> addFileEtagHeaders(req, fullFilePath);
}

let static = (basePath, pathList, req: Req.t('a), res) => {
  let fullFilePath = Static.getFilePath(basePath, pathList);
  let%lwt exists = Lwt_unix.file_exists(fullFilePath);
  switch (exists) {
    | true =>
      let%lwt stats = Lwt_unix.stat(fullFilePath);
      let%lwt resWithHeaders = addStaticHeaders(req, fullFilePath, stats, res);

      let response = createResponse(resWithHeaders);
      let requestDescriptor = Req.reqd(req);
      let responseBody =
        Httpaf.Reqd.respond_with_streaming(requestDescriptor, response);
      let%lwt () = streamFileContentsToBody(fullFilePath, responseBody);
      Lwt.return @@ closeResponse @@ resWithHeaders;
    | _ =>
      let resWithHeaders =
        status(404, res) |> addHeader(("Content-Length", "9")) |> addHeader(("Connection", "keep-alive"));
      let response = createResponse(resWithHeaders);
      let responseBody =
        Httpaf.Reqd.respond_with_streaming(Req.reqd(req), response);
      Httpaf.Body.write_string(responseBody, "Not found");
      Httpaf.Body.close_writer(responseBody);
      Lwt.return @@ closeResponse @@ resWithHeaders;
  }
};

let setSessionCookies = (newSessionId, sessionIdKey, maxAge, res) => {
  let setCookieKey = "Set-Cookie";
  let maxAgeStr = string_of_int(maxAge);

  addHeader(
    (
      setCookieKey,
      sessionIdKey ++ "=" ++ newSessionId ++ "; Max-Age=" ++ maxAgeStr ++ ";",
    ),
    res,
  );
};

let redirect = (path, req, res) => {
  status(302, res) |> addHeader(("Location", path)) |> text(req, "Found");
};

let reportError = (exn, req: Req.t('a), res) => {
  Httpaf.Reqd.report_exn(Req.reqd(req), exn);
  Lwt.return @@ closeResponse({...res, exn: Some(exn)});
};

let writeChannel = (req: Req.t('a), res) => {
  let reqd = Req.reqd(req);
  let resWithHeaders = addHeader(("Transfer-encoding", "chunked"), res)
    |> addHeader(("Connection", "keep-alive"));

  let responseBody = resWithHeaders
    |> createResponse
    |> Httpaf.Reqd.respond_with_streaming(~flush_headers_immediately=true, reqd);

  let onWrite = (bytes, off, len) => {
    Httpaf.Body.write_bigstring(~off, ~len, responseBody, bytes);
    Lwt.return(len);
  };

  let (respPromise, respResolver) = Lwt.task();

  let close = () => {
    Httpaf.Body.close_writer(responseBody);
    Lwt.wakeup(respResolver, closeResponse(resWithHeaders));
    Lwt.return_unit;
  };

  (Lwt_io.make(
    ~close,
    ~mode=Output,
    onWrite
  ), respPromise);
};