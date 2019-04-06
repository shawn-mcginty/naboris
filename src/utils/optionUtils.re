let map = (f, opt) =>
  switch (opt) {
  | None => None
  | Some(x) => Some(f(x))
  };

let flatMap = (f: 'a => option('b), opt: option('a)) =>
  switch (opt) {
  | None => None
  | Some(x) => f(x)
  };

let foo = () => {
  print_string("Foo");
};