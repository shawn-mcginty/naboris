type 'sessionData t = {
  requestDescriptor : Httpaf.Reqd.t;
  session : 'sessionData Session.t option;
  sidKey : string;
  maxAge : int;
  secret : string;
  staticCacheControl : string option;
  staticLastModified : bool;
  responseEtag : Etag.strength option;
}

let reqd req = req.requestDescriptor

let getHeader headerKey req =
  match Httpaf.Reqd.request req.requestDescriptor with
  | {headers; _} -> Httpaf.Headers.get headers headerKey

let getBody {requestDescriptor; _} =
  let body = Httpaf.Reqd.request_body requestDescriptor in
  let (bodyStream, pushToBodyStream) = Lwt_stream.create () in

  let rec on_read bigstr ~off:_ ~len:_ =
    let str = Bigstringaf.to_string bigstr in
    pushToBodyStream (Some str);
    Httpaf.Body.schedule_read body ~on_read ~on_eof
  and on_eof () = pushToBodyStream None in

  Httpaf.Body.schedule_read body ~on_read ~on_eof;

  Lwt_stream.fold (fun a b -> a ^ b) bodyStream ""

let fromReqd reqd sessionConfig staticCacheControl staticLastModified responseEtag =
  let sidKey = SessionConfig.sidKey sessionConfig in
  let maxAge =SessionConfig.maxAge sessionConfig in
  let secret = SessionConfig.secret sessionConfig in
  let defaultReq = {requestDescriptor = reqd; session = None; sidKey; maxAge; secret; staticCacheControl; staticLastModified; responseEtag} in
  defaultReq

let getSessionData req =
  match req.session with
  | None -> None
  | Some session -> Some (Session.data session)

let setSessionData maybeSession req =
  {req with session = maybeSession}

let sidKey req = req.sidKey

let maxAge req = req.maxAge

let secret req = req.secret

let staticCacheControl req = req.staticCacheControl

let staticLastModified req = req.staticLastModified

let responseEtag req = req.responseEtag 