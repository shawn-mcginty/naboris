type t = {
  requestDescriptor: Httpaf.Reqd.t(Lwt_unix.file_descr),
  params: list((string, string)),
  query: list((string, list(string))),
};

let fromReqd = (reqd, params, query) => {
  requestDescriptor: reqd,
  params,
  query,
};