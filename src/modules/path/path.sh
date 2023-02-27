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

# Command appears to be unreachable. Check usage (or ignore if invoked indirectly).
# shellcheck disable=SC2317

################################################################################
__bl_path_canonicalize_load() {
	# __bl_module_load __bl_some_other_module

	__bl_path_canonicalize() {
		local -a components
		local -a components_new
		local component

		__bl_return="${1}"

		if [[ "${__bl_return}" != /* ]]; then
			__bl_return="${PWD}/${__bl_return}"
		fi

		# Remove duplicated slashes (ie: //// -> /)
		while [[ "${__bl_return}" =~ (.*)//+(.*) ]]; do
			__bl_return="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
		done

		# Resolve current path (ie: /./ -> /)
		while [[ "${__bl_return}" =~ (.*)"/."(/.*)?$ ]]; do
			__bl_return="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
		done

		# Resolve parent path (ie: /bin/../home -> /home)
		IFS="/" read -r -a components <<< "${__bl_return#/}"
		components_new=()
		for component in "${components[@]}"; do
			if [[ "${component}" == .. ]]; then
				if [[ "${#components_new[@]}" -gt 0 ]]; then
					unset "components_new[${#components_new[@]}-1]"
				fi
			else
				components_new+=( "${component}" )
			fi
		done
		__bl_return=""
		for component in "${components_new[@]}"; do
			__bl_return+="/${component}"
		done
		[[ "${__bl_return}" == "" ]] && __bl_return="/"

		# Remove trailing slash
		if [[ "${__bl_return}" =~ (.*[^/]+)/+$ ]]; then
			__bl_return="${BASH_REMATCH[1]}"
		fi
	}
}

# vim: set ft=sh:
