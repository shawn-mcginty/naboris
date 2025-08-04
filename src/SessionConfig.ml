type 'sessionData t = {
  getSession : string option -> 'sessionData Session.t option Lwt.t;
  sidKey : string;
  maxAge : int;
  secret : string;
}

let maxAge conf = match conf with
  | Some sessConf -> sessConf.maxAge
  | _ -> 2592000

let sidKey conf = match conf with
  | Some sessConf -> sessConf.sidKey
  | _ -> "nab.sid"

let secret conf = match conf with
  | Some sessConf -> sessConf.secret
  | _ -> "Keep it secret, keep it safe!" 