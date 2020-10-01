type httpaf_config = {
  read_buffer_size : int;
  request_body_buffer_size : int;
  response_buffer_size : int;
  response_body_buffer_size : int;
}

type 'sessionData t = {
  on_listen : unit -> unit;
  route_request : Route.t -> 'sessionData Req.t -> Res.t -> Res.t Lwt.t;
  session_config : 'sessionData SessionConfig.t option;
  error_handler : ErrorHandler.t option;
  httpaf_config : httpaf_config option;
  middlewares : 'sessionData Middleware.t list;
  static_cache_control : string option;
  static_last_modified : bool;
  etag : Etag.strength option;
}

let default =
  {
    on_listen = (fun () -> ());
    error_handler = None;
    route_request =
      (fun _route req res ->
        res |> Res.status 404 |> Res.raw req "Resource not found");
    session_config = None;
    httpaf_config = None;
    middlewares = [];
    static_cache_control = Some "public, max-age=0";
    static_last_modified = true;
    etag = Some `Weak;
  }

let session_config conf = conf.session_config

let error_handler conf = conf.error_handler

let route_request conf = conf.route_request

let on_listen conf = conf.on_listen

let make () = default

let set_on_listen on_listen_fn conf = { conf with on_listen = on_listen_fn }

let set_request_handler req_handler_fn conf =
  { conf with route_request = req_handler_fn }

let set_error_handler err_handler_fn conf =
  { conf with error_handler = Some err_handler_fn }

let add_middleware middleware conf =
  { conf with middlewares = List.append conf.middlewares [ middleware ] }

let middlewares conf = conf.middlewares

let rec match_paths matcher path =
  let _ = print_endline ("matcher: " ^ List.hd matcher) in
  let _ = print_endline ("path: " ^ List.hd path) in
  match (matcher, path) with
  | [ x ], y :: rest when x = y -> Some rest
  | x :: rest_matcher, y :: rest_path when x = y ->
      match_paths rest_matcher rest_path
  | _ ->
      let _ = print_endline "no matches MF" in
      None

let add_static_middleware path_prefix public_path conf =
  conf
  |> add_middleware (fun next route req res ->
         match (Route.meth route, Route.path route) with
         | Method.GET, path -> (
             match match_paths path_prefix path with
             | Some remaining_path ->
                 Res.static public_path remaining_path req res
             | _ -> next route req res )
         | _ -> next route req res)

let set_session_config ?(max_age = 2592000) ?(sid_key = "nab.sid")
    ?(secret = "please set to a secure value") get_session_fn conf =
  let session_config : 'sessionData SessionConfig.t =
    { get_session = get_session_fn; max_age; sid_key; secret }
  in
  { conf with session_config = Some session_config }

let static_cache_control conf = conf.static_cache_control

let set_static_cache_control cache_control conf =
  { conf with static_cache_control = cache_control }

let static_last_modified conf = conf.static_last_modified

let set_static_last_modified static_last_modified conf =
  { conf with static_last_modified }

let etag conf = conf.etag

let set_etag etag conf = { conf with etag }

let httpaf_config (conf : 'sessionData t) : Httpaf.Config.t option =
  match conf.httpaf_config with
  | None -> None
  | Some httpaf_conf ->
      let {
        read_buffer_size;
        request_body_buffer_size;
        response_buffer_size;
        response_body_buffer_size;
      } =
        httpaf_conf
      in
      Some
        {
          read_buffer_size;
          request_body_buffer_size;
          response_buffer_size;
          response_body_buffer_size;
        }

let set_httpaf_config httpaf_conf conf =
  { conf with httpaf_config = Some httpaf_conf }
