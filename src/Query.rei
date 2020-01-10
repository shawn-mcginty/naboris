/**
 Implements {{: https://caml.inria.fr/pub/docs/manual-ocaml/libref/Map.Make.html} Map}
 with [key] of [string].
 */
module QueryMap : Map.S with type key = String.t;