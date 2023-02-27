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
	local script_full_path
	local script_name
	local -a what
	local -a from
	local w f relative_path
	local bashlib_path

	script_name="helper__bl_bashlib_path"
	script_full_path=$(dirname "${0}")  # Get this script path
	script_full_path+="/../${script_name}"  # Point to ../<script_name>
	script_full_path=$(readlink -f "${script_full_path}")

	bashlib_path="$(readlink -f "${script_full_path}/../../src")"

	what+=( "${script_full_path}/${script_name}.sh" )
	what+=( "${script_full_path}/${script_name}.standalone.sh" )

	from+=( "/" )
	from+=( "${script_full_path}" )
	from+=( "$( readlink -f "${script_full_path}/..")" )

	for w in "${what[@]}"; do
		for f in "${from[@]}"; do
			cd "${f}"
				# <program> <expected bashlib_path> <expected program path>
				echo
				echo "PWD(${PWD}) ${w} bashlib_path(${bashlib_path})"
				"${w}" "${bashlib_path}" "${w}"

				echo
				relative_path="$(realpath --relative-to="${PWD}" "${w}")"
				echo "PWD(${PWD}) ./${relative_path} bashlib_path(none)"
				"./${relative_path}" "${bashlib_path}" "${w}"

				echo
				echo "PWD(${PWD}) bash ${w} bashlib_path(${bashlib_path}) program_path(${w})"
				bash "${w}" "${bashlib_path}" "${w}"

				echo
				relative_path="$(realpath --relative-to="${PWD}" "${w}")"
				echo "PWD(${PWD}) bash ./${relative_path} bashlib_path(none) program_path(${w})"
				bash "./${relative_path}" "${bashlib_path}" "${w}"

				echo
				relative_path="$(realpath --relative-to="${PWD}" "${w}")"
				echo "PWD(${PWD}) bash ${relative_path} bashlib_path(none) program_path(${w})"
				bash "${relative_path}" "${bashlib_path}" "${w}"
		done
	done
}

main "${@}"

# vim: set ft=sh:
