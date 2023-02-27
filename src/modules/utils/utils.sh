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
__bl_temp_path_get_load() {
	__bl_temp_path_get() {
		declare -g __bl_temp_path

		if [[ -w "/tmp" ]]; then
			__bl_temp_path="/tmp/__bl_temp_path.${EUID}"
		elif [[ -w "/dev/shm" ]]; then
			__bl_temp_path="/dev/shm/__bl_temp_path.${EUID}"
		else
			echo "[error] could not set __bl_temp_path, neither /tmp or /dev/shm are writeable."
			return 1
		fi

		if ! [[ -d "${__bl_temp_path}" ]]; then
			mkdir -p "${__bl_temp_path}/"{log,pid,data,var}
			# fifo for pseudo sleep __bl_sleep
			mkfifo -m 700 "${__bl_temp_path}/var/fifo"
		fi
		[[ "${1:-}" == "--quiet" ]] || echo "${__bl_temp_path}"
	}
}

################################################################################
__bl_version_string_load() {
	__bl_version_string() {
		local -i i next
		local remaining
		local mode
		local output_integer
		local output_string=""

		mode="${1}"
		remaining="${2}"

		remaining=".${remaining}"

		for i in {1..5}; do
			if [[ "${remaining}" =~ ^.([0-9]+)*[^0-9.]*(\..*)? ]]; then
				next="${BASH_REMATCH[1]}"
				remaining="${BASH_REMATCH[2]}"
				output_string+="${next}."
			else
				next=0
			fi
			printf -v output_integer "%s%04d" "${output_integer:-0}" "${next}"
		done

		[[ -z "${output_integer:-}" ]] && output_integer=0

		# Remove leading zeros
		[[ "${output_integer}" =~ ^0+(.*)$ ]] && output_integer="${BASH_REMATCH[1]}"
		[[ "${output_integer}" ]] || output_integer=0

		case "${mode}" in
			integer) __bl_return="${output_integer}" ;;
			string) __bl_return="${output_string%.}" ;;
		esac
	}
}

# vim: set ft=sh:
