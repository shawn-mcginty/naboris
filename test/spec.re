type t = {
	test: unit => Lwt.t((TestResult.t, float)),
	title: string
};