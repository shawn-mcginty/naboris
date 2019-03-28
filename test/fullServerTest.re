open Lwt.Infix;

let testServer: Naboris.Server.server = {
	onListen: () => {
		print_string(" 🐫 Started a server on port 9991!\n");
		print_newline();
		exit(0);
	}
};

let serverRunning = Naboris.listen(9991, testServer);

let timeout = Lwt_unix.sleep(5.0) >>= () => Lwt.return(None);

let run = () => {
	switch (Lwt.pick([timeout, serverRunning]) |> Lwt_main.run) {
		| None => {
			print_string("🚫 Timed out after 5 seconds!");
			print_newline();
			exit(1);
		}
		| _ => exit(0)
	}
};

run();