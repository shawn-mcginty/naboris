#!/bin/bash
set -e
esy @libev install
esy @libev b dune runtest