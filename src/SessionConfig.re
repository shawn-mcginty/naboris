type t('sessionData) = {
  getSession: option(string) => Lwt.t(option(Session.t('sessionData))),
  sidKey: string,
  maxAge: int,
  secret: string,
};

let maxAge = conf => switch(conf) {
  | Some(sessConf) => sessConf.maxAge
  | _ => 2592000
};

let sidKey = conf => switch(conf) {
  | Some(sessConf) => sessConf.sidKey
  | _ => "nab.sid"
};

let secret = conf => switch(conf) {
  | Some(sessConf) => sessConf.secret
  | _ => "Keep it secret, keep it safe!"
}