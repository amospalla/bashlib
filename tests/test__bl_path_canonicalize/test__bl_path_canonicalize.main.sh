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

check() {
	local expected_path
	local obtained_path

	expected_path="$(realpath -m "${1}")"

	__bl_path_canonicalize "${1}"
	obtained_path="${__bl_return}"

	if [[ "${expected_path}" != "${obtained_path}" ]]; then
		echo "Error: Input: '${1}', obtained_path: '${obtained_path}', expected_path:'${expected_path}'."
		exit 1
	# else
	# 	echo "OK: Input: '${1}', obtained_path: '${obtained_path}', expected_path:'${expected_path}'."
	fi
}

main() {
	local -a strings
	local string1 string2 string3 string4 string5

	strings=(foo bar . .. / /. /.. // ///)
	for string1 in "${strings[@]}"; do
		for string2 in "${strings[@]}"; do
			for string3 in "${strings[@]}"; do
				for string4 in "${strings[@]}"; do
					for string5 in "${strings[@]}"; do
						check "${string1}${string2}${string3}${string4}${string5}"
					done
				done
			done
		done
	done
}

main "${@}"

# vim: set ft=sh:
