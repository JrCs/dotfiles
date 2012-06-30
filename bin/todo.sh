#! /bin/bash

# Wrapper to todo.sh to avoid putting todo.txt-cli in the PATH
exec "${0%/*}/../todo.txt-cli/todo.sh" $@
