type strength = [`Weak | `Strong]

let fromString entity = match String.length entity with
	| 0 -> "\"0-2jmj7l5rSw0yVb/vlWAYkK/YBwk\"" (* empty entity, use hardcoded empty etag *)
	| len ->
		let etag = Digestif.digest_string Digestif.sha1 entity
			|> Digestif.to_raw_string Digestif.sha1
			|> Base64.encode_exn in
		
		let maxLen = match String.length etag with
			| x when x < 27 -> x
			| _ -> 27
		in

		"\"" ^ string_of_int len ^ "-" ^ String.sub etag 0 maxLen ^ "\""

let weakFromString entity = "W/" ^ fromString entity

let fromFilePath path : string Lwt.t =
	let%lwt stats = Lwt_unix.stat path in
	let size = string_of_int stats.st_size in
	fromString (size ^ path) |> Lwt.return

let weakFromPath path =
	let%lwt etag = fromFilePath path in
	Lwt.return ("W/" ^ etag) 