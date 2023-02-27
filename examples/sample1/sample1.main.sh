#!/usr/bin/env bash

main() {
    __bl_log debug debug
    __bl_log info info
    __bl_log warning warning
    __bl_log error error
    __bl_log critical critical
    __bl_echo_color green "sleep for 0.5 seconds"
	__bl_sleep 0.5
    false
    true
    echo end
}

# vim: set ft=sh:
