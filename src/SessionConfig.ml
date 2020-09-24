type 'sessionData t = {
  get_session : string option -> 'sessionData Session.t option Lwt.t;
  sid_key : string;
  max_age : int;
  secret : string;
}

let max_age conf =
  match conf with Some sess_conf -> sess_conf.max_age | _ -> 2592000

let sid_key conf =
  match conf with Some sess_conf -> sess_conf.sid_key | _ -> "nab.sid"

let secret conf =
  match conf with
  | Some sess_conf -> sess_conf.secret
  | _ -> "Keep it secret, keep it safe!"
