type strength = [ `Weak | `Strong ]

let empty_entity_etag = "\"0-2jmj7l5rSw0yVb/vlWAYkK/YBwk\""

let of_string entity =
  match String.length entity with
  | 0 -> empty_entity_etag
  | len ->
      let etag =
        Digestif.digest_string Digestif.sha1 entity
        |> Digestif.to_raw_string Digestif.sha1
        |> Base64.encode_exn
      in

      let max_len =
        match String.length etag with x when x < 27 -> x | _ -> 27
      in

      "\"" ^ string_of_int len ^ "-" ^ String.sub etag 0 max_len ^ "\""

let weak_of_string entity = "W/" ^ of_string entity

let of_file_path path =
  let%lwt stats = Lwt_unix.stat path in
  let size = string_of_int stats.st_size in
  of_string (size ^ path) |> Lwt.return

let weak_of_path path =
  let%lwt etag = of_file_path path in
  Lwt.return ("W/" ^ etag)
