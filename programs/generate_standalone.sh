#!/usr/bin/env bash

set -eu -o pipefail -o errtrace

# For each folder, create its standalone script:
#     Executes: <name>/<name>.sh.

main(){
	local mypath="${0%/*}"  # path for running script
	local program_name  # name for discrete program

	for program_name in "${mypath}"/*; do
		if [[ -d "${program_name}" ]]; then
			program_name="${program_name##*/}"
			# With __bl_generate_standalone_filename set, the program doesn't actually run, but only generate
			# a standalone version of itself in the path specified by this variable.
			export __bl_generate_standalone_filename="${mypath}/${program_name}/${program_name}.standalone.sh"
			"${mypath}/${program_name}/${program_name}.sh"
		fi
	done
}

main "${@}"

# vim: set ft=sh:
