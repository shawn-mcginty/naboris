type t = {
	requestDescriptor: Httpaf.Reqd.t(Lwt_unix.file_descr),
};

let fromReqd = (reqd) => {requestDescriptor: reqd};
