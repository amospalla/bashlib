#!/usr/bin/env bash

# Copyright (c) 2023 Jordi Marqués
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
