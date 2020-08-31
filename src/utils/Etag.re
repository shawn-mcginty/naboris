type strength = [`Weak | `Strong];

let fromString = (entity) => switch(String.length(entity)) {
	| 0 => "\"0-2jmj7l5rSw0yVb/vlWAYkK/YBwk\"" // empty entity, use hardcoded empty etag
	| len =>
		let etag = Digestif.digest_string(Digestif.sha1, entity)
			|> Digestif.to_raw_string(Digestif.sha1)
			|> Base64.encode_exn;
		
		let maxLen = switch(String.length(etag)) {
			| x when x < 27 => x
			| _ => 27
		};

		"\"" ++ string_of_int(len) ++ "-" ++ String.sub(etag, 0, maxLen) ++ "\"";
};

let weakFromString = (entity) => "W/" ++ fromString(entity);

let fromFilePath = (path) : Lwt.t(string) => {
	let%lwt stats = Lwt_unix.stat(path);
	let size = string_of_int(stats.st_size);
	fromString(size ++ path) |> Lwt.return;
};

let weakFromPath = (path) => {
	let%lwt etag = fromFilePath(path);
	Lwt.return("W/" ++ etag);
};