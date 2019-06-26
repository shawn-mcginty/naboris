type sessionConfig('sessionData) = {
  onRequest: option(string) => Lwt.t(option(Session.t('sessionData))),
};

type t('sessionData) = {
  onListen: unit => unit,
  routeRequest: (Route.t, Req.t('sessionData), Res.t) => Lwt.t(unit),
  sessionConfig: option(sessionConfig('sessionData)),
};