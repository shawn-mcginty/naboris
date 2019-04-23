type t = {
  requestDescriptor: Httpaf.Reqd.t(Lwt_unix.file_descr),
  params: list((string, string)),
};

let fromReqd = (reqd, params) => {requestDescriptor: reqd, params};