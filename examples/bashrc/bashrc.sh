#!/usr/bin/env bash

if [[ "${0}" == */* ]]; then
	. "${0%/*}/../../src/main.sh"  # This file has been invoked including a path
else
	. "../../src/main.sh"  # This file has been invoked from the same path without directory component
fi

__bl_generate_standalone_interactive=1
__bl_run_main "${@}"

# vim: set ft=sh: