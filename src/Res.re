open Lwt.Infix;

type t = {
  status: int,
  headers: list((string, string)),
};

let default = () => {status: 200, headers: []};

let createResponse = (res: t) => {
  Httpaf.Response.create(
    ~headers=Httpaf.Headers.of_list(res.headers),
    Httpaf.Status.of_code(res.status),
  );
};

let addHeader = (header: (string, string), res: t) => {
  {...res, headers: [header, ...res.headers]};
};

let status = (status: int, res: t) => {
  {...res, status};
};

let raw = (req: Req.t('a), body: string, res: t) => {
  let resWithHeaders = addHeader(("Content-length", String.length(body) |> string_of_int), res);
  let response = createResponse(resWithHeaders);
  let requestDescriptor = Req.reqd(req);

  let responseBody =
    Httpaf.Reqd.respond_with_streaming(requestDescriptor, response);
  Httpaf.Body.write_string(responseBody, body);
  Httpaf.Body.close_writer(responseBody);
  Lwt.return_unit;
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
  Lwt_unix.openfile(fullFilePath, readOnlyFlags, readOnlyPerm) >>= ((fd) => {
    let channel = Lwt_io.of_fd(fd, ~mode=Lwt_io.Input);
    let bufferSize = 512;
    let rec pipeBody = (~count, ch, body) =>
      Lwt.bind(
        Lwt_io.read(~count, ch),
        chunk => {
          Httpaf.Body.write_string(body, chunk);
          String.length(chunk) < count
            ? {
              Lwt.return_unit;
            }
            : pipeBody(~count, ch, body);
        },
      );
    Lwt.finalize(
      () => pipeBody(~count=bufferSize, channel, responseBody),
      () => {
        Httpaf.Body.close_writer(responseBody);
        Lwt_io.close(channel);
      },
    );
  });
};

let static = (basePath, pathList, req: Req.t('a), res) => {
  let fullFilePath = Static.getFilePath(basePath, pathList);
  Lwt_unix.file_exists(fullFilePath) >>= ((exists) => switch (exists) {
    | true =>
      Lwt_unix.stat(fullFilePath) >>= ((stats) => {
        let size = stats.st_size;
        let resWithHeaders =
          addHeader(("Content-Type", MimeTypes.getMimeType(fullFilePath)), res)
          |> addHeader(("Content-Length", string_of_int(size)));
        let response = createResponse(resWithHeaders);
        let requestDescriptor = Req.reqd(req);
        let responseBody =
          Httpaf.Reqd.respond_with_streaming(requestDescriptor, response);
        streamFileContentsToBody(fullFilePath, responseBody);
      });
    | _ =>
      let resWithHeaders =
        status(404, res) |> addHeader(("Connection", "close"));
      let response = createResponse(resWithHeaders);
      let responseBody =
        Httpaf.Reqd.respond_with_streaming(Req.reqd(req), response);
      Httpaf.Body.write_string(responseBody, "Not found");
      Httpaf.Body.close_writer(responseBody);
      Lwt.return_unit;
    });
};

let setSessionCookies = (newSessionId, res) => {
  let setCookieKey = "Set-Cookie";
  let thirtyDays = string_of_int(30 * 24 * 60 * 60);
  let sessionIdKey = "nab.sid";

  addHeader(
    (
      setCookieKey,
      sessionIdKey ++ "=" ++ newSessionId ++ "; Max-Age=" ++ thirtyDays ++ ";",
    ),
    res,
  );
};

let redirect = (path, req, res) => {
  status(302, res) |> addHeader(("Location", path)) |> text(req, "Found");
};

let reportError = (req: Req.t('a), exn) => {
  Httpaf.Reqd.report_exn(Req.reqd(req), exn);
};