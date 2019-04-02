let map = (f: ('a) => 'b, opt: option('a)) => switch(opt) {
| None => None;
| Some(x) => Some(f(x));
};

let flatMap = (f: ('a) => option('b), opt: option('a)) => switch(opt) {
	| None => None;
	| Some(x) => f(x);
	};