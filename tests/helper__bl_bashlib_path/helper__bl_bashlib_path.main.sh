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

main() {
	local in_bashlib_path
	local in_path
	local in_name

	in_bashlib_path="${1}"
	in_path="${2%/*}"
	in_name="${2##*/}"


	if [[ -z "${__bl_bashlib_path:-}" ]]; then
		__bl_echo_color gray "bashlib path n/a"
	elif [[ "${in_bashlib_path}" == "$(readlink -f "${__bl_bashlib_path:-}")" ]]; then
		__bl_echo_color green "__bl_bashlib_path '${__bl_bashlib_path}'"
	else
		__bl_echo_color red "__bl_bashlib_path expected '${in_bashlib_path}', but got: '${__bl_bashlib_path:-}'"
		exit 1
	fi

	if [[ "${in_path}" == "$(readlink -f "${__bl_program_path}")" ]]; then
		__bl_echo_color green "__bl_program_path '${__bl_program_path}'"
	else
		__bl_echo_color red "__bl_program_path '${__bl_program_path}'"
		exit 1
	fi

	if [[ "${in_path}/${in_name}" == "$(readlink -f "${__bl_program_path}/${__bl_program_name}")" ]]; then
		__bl_echo_color green "__bl_program_name '${__bl_program_name}'"
	else
		__bl_echo_color red "__bl_program_name '${in_path} / ${in_name}'  '${__bl_program_path} / ${__bl_program_name}'"
		exit 1
	fi
}

# vim: set ft=sh:
