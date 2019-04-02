type t = 
	| GET
	| POST
	| PUT
	| PATCH
	| DELETE
	| CONNECT
	| OPTIONS
	| TRACE
	| Other(string);

let ofString = (str) => {
	switch (str) {
	| "GET" => GET;
	| "POST" => POST;
	| "PUT" => PUT;
	| "PATCH" => PATCH;
	| "DELETE" => DELETE;
	| "CONNECT" => CONNECT;
	| "OPTIONS" => OPTIONS;
	| "TRACE" => TRACE;
	| s => Other(s);
	}
};

let toString = (method) => {
	switch (method) {
	| GET => "GET";
	| POST => "POST";
	| PUT => "PUT";
	| PATCH => "PATCH";
	| DELETE => "DELETE";
	| CONNECT => "CONNECT";
	| OPTIONS => "OPTIONS";
	| TRACE => "TRACE";
	| Other(s) => s;
	}
}

	let ofHttpAfMethod = (meth) => {
		let methodString = Httpaf.Method.to_string(meth)
		ofString(methodString);
	};