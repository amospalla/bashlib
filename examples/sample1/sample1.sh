#!/usr/bin/env bash

if [[ "${0}" == */* ]]; then
	. "${0%/*}/../../src/main.sh"  # This file has been invoked including a path
else
	. "../../src/main.sh"  # This file has been invoked from the same path without directory component
fi

__bl_module_load __bl_echo_color
__bl_module_load __bl_log
__bl_module_load __bl_sleep
__bl_module_load __bl_trap_error

__bl_run_main "${@}"

# vim: set ft=sh:
