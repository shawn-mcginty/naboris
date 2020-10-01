let rec get_session_id sid_key cookie_str =
  let session_key = sid_key ^ "=" in
  let cookie_length = String.length cookie_str in
  let key_length = String.length session_key in
  let start_of_string = 0 in

  match String.index_opt cookie_str session_key.[start_of_string] with
  | None -> None
  | Some i ->
      let highest_len = key_length + i in
      if cookie_length < highest_len then None
      else if String.sub cookie_str i key_length = session_key then
        let partial_cookie =
          String.sub cookie_str highest_len (cookie_length - highest_len)
        in

        match String.index_opt partial_cookie ';' with
        | None -> Some partial_cookie
        | Some end_of_cookie ->
            Some (String.sub partial_cookie start_of_string end_of_cookie)
      else
        get_session_id sid_key
          (String.sub cookie_str (i + 1) (cookie_length - (i + 1)))

let session_id_of_req req =
  match Req.get_header "Cookie" req with
  | None -> None
  | Some header -> get_session_id (Req.sid_key req) header
