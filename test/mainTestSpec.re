open Lwt.Infix;

let tests = [
	Spec.{
		title: "Get \"/this-should-never-exist\" returns a 404 by default",
		test: () => {
			Cohttp_lwt_unix.Client.get(Uri.of_string("http://localhost:9991/this-should-never-exist"))
			>>= ((resp, _bod)) => {
				assert(resp.status == `Not_found);
				Lwt.return((TestResult.TestDone, 0.0));
			}
		}
	},
	Spec.{
		title: "Get \"/html\" returns a 200 and html document",
		test: () => {
			Cohttp_lwt_unix.Client.get(Uri.of_string("http://localhost:9991/html"))
			>>= ((resp, bod)) => {
				assert(resp.status == `OK);
				Cohttp_lwt.Body.to_string(bod) >>= (bodyStr) => {
					assert(bodyStr == "<!doctype html><html><body>You made it.</body></html>");
					Lwt.return((TestResult.TestDone, 0.0));
				};
			}
		}
	},
	Spec.{
		title: "Get \"/user/:userId/item/:itemId\" matches with integers",
		test: () => {
			Cohttp_lwt_unix.Client.get(Uri.of_string("http://localhost:9991/user/1/item/0"))
			>>= ((resp, bod)) => {
				assert(resp.status == `OK);
				Cohttp_lwt.Body.to_string(bod) >>= (bodyStr) => {
					assert(bodyStr == "<!doctype html><html><body>You want some user id and item</body></html>");
					Lwt.return((TestResult.TestDone, 0.0));
				};
			};
		}
	},
	Spec.{
		title: "Get \"/user/:userId/item/:itemId\" matches with uuids",
		test: () => {
			Cohttp_lwt_unix.Client.get(Uri.of_string("http://localhost:9991/user/bfdb66ad-f974-4293-acf9-dfda390abdc4/item/8f146ab9-94d1-46a9-bd0f-2079e22314f4"))
			>>= ((resp, bod)) => {
				assert(resp.status == `OK);
				Cohttp_lwt.Body.to_string(bod) >>= (bodyStr) => {
					assert(bodyStr == "<!doctype html><html><body>You want some user id and item</body></html>");
					Lwt.return((TestResult.TestDone, 0.0));
				};
			};
		}
	}
];