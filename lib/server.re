module Body = Httpaf.Body;
module Headers = Httpaf.Headers;
module Reqd = Httpaf.Reqd;
module Response = Httpaf.Response;
module Status = Httpaf.Status;

type server = {
	onListen: unit => unit
};

let buildConnectionHandler = (_server) => {
	let request_handler = (_client_address: Unix.sockaddr, request_descriptor) => {
			let response =
				Response.create(
					~headers=
						Headers.of_list([
							("Content-Type", "application/json"),
							("Connection", "close"),
						]),
					`Not_found,
				);

			let response_body =
				Reqd.respond_with_streaming(request_descriptor, response);

			let respond = () =>
				Body.write_string(response_body, "Page not found.");

			respond();
		};

	let error_handler = (_client_address: Unix.sockaddr, ~request as _=?, error, start_response) => {
			let response_body = start_response(Headers.empty);

			switch (error) {
			| `Exn(exn) =>
				Body.write_string(response_body, Printexc.to_string(exn));
				Body.write_string(response_body, "\n");

			| #Status.standard as error =>
				Body.write_string(response_body, Status.default_reason_phrase(error))
			};

			Body.close_writer(response_body);
		};

	Httpaf_lwt.Server.create_connection_handler(
		~config=?None,
		~request_handler,
		~error_handler,
	);
};