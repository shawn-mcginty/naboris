let raiseFailure = msg => raise(Assert_failure((msg, 0, 0)));

let areSame = (x, y) =>
  switch (x == y) {
  | false =>
    raiseFailure("Expected \"" ++ x ++ "\" to be same as \"" ++ y ++ "\"")
  | _ => ()
  };