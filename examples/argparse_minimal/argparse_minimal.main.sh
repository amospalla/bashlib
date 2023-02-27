#!/usr/bin/env bash

main() {
	__bl_argparse "" "${@}"
	__bl_echo_color green "argparser succeeded, we executed the program without any parameter."
}

# vim: set ft=sh:
