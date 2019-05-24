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

let html = (req: Req.t, htmlBody: string, res: t) => {
  let resWithHeaders =
    addHeader(("Content-Type", "text/html"), res)
    |> addHeader(("Connection", "close"));
  let response = createResponse(resWithHeaders);
  let requestDescriptor = req.requestDescriptor;

  let responseBody =
    Httpaf.Reqd.respond_with_streaming(requestDescriptor, response);
  Httpaf.Body.write_string(responseBody, htmlBody);
  Httpaf.Body.close_writer(responseBody);
};

let streamFileContentsToBody = (fullFilePath, responseBody) => {
  let readOnlyFlags = [Unix.O_RDONLY];
  let readOnlyPerm = 444;
  let fd = Unix.openfile(fullFilePath, readOnlyFlags, readOnlyPerm);
  let channel = Lwt_io.of_unix_fd(fd, ~mode=Lwt_io.Input);
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
  Lwt.bind(
    pipeBody(~count=bufferSize, channel, responseBody),
    () => {
      Httpaf.Body.close_writer(responseBody);
      Lwt.return_unit;
    },
  );
};

let static = (basePath, pathList, req: Req.t, res) => {
  let fullFilePath = Static.getFilePath(basePath, pathList);
  let resWithHeaders =
    addHeader(("Content-Type", MimeTypes.getMimeType(fullFilePath)), res)
    |> addHeader(("Connection", "close"));
  let response = createResponse(resWithHeaders);
  let requestDescriptor = req.requestDescriptor;
  let responseBody =
    Httpaf.Reqd.respond_with_streaming(requestDescriptor, response);
  streamFileContentsToBody(fullFilePath, responseBody);
};