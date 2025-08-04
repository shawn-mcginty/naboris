.PHONY: install build test clean

# Create a new opam switch
switch:
	opam switch create . --no-install

# Install project dependencies
install:
	opam install . --deps-only --with-test --confirm-level unsafe-yes

build:
	dune build

test:
	dune runtest

clean:
	dune clean
