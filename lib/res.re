type t = {
	status: int,
	headers: list((string, string))
};

let default = () => {status: 200, headers: []};

let createResponse = (res: t) => {
	Httpaf.Response.create(
		~headers=Httpaf.Headers.of_list(res.headers),
		Httpaf.Status.of_code(res.status)
	);
};

let addHeader = (header: (string, string), res: t) => {
	{...res, headers: [header, ...res.headers]};
};

let status = (status: int, res: t) => {
	{...res, status: status};
};

let html = (req: Req.t, htmlBody: string, res: t) => {
	let resWithHeaders = addHeader(("Content-Type", "text/html"), res)
		|> addHeader(("Connection", "close"));
	let response = createResponse(resWithHeaders);
	let requestDescriptor = req.requestDescriptor;

	let responseBody = Httpaf.Reqd.respond_with_streaming(requestDescriptor, response);
	Httpaf.Body.write_string(responseBody, htmlBody);
	Httpaf.Body.close_writer(responseBody);
};