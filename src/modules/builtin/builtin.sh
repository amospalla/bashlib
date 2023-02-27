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
__bl_load_bash_builtin_load() {
	__bl_load_bash_builtin() {
		# rmdir has not -p parameter.
		# sleep has no s|m|h|d suffix support
		local BASH_LOADABLES_PATH
		BASH_LOADABLES_PATH="/usr/lib/bash"
		if [[ -f "${BASH_LOADABLES_PATH}/${1}" ]]; then
			if enable -f "${1}" "${1}"; then
				return 0
			fi
		fi
		return 1
	}
}

################################################################################
__bl_sleep_load() {
	__bl_module_load __bl_temp_path_get

	__bl_sleep() {
		# https://blog.dhampir.no/content/sleeping-without-a-subprocess-in-bash-and-how-to-sleep-forever
		local IFS
		local time
		local seconds

		if [[ "${1}" == "inf" ]]; then
			seconds=0
		else
			time="${1}"

			case "${time: -1}" in
				s) seconds="${time:0: -1}" ;;
				m) seconds="$(( ${time:0: -1} * 60 ))" ;;
				h) seconds="$(( ${time:0: -1} * 3600 ))" ;;
				d) seconds="$(( ${time:0: -1} * 86400 ))" ;;
				*) seconds="${time}" ;;
			esac
		fi
			
		[[ -n "${_snore_fd:-}" ]] || { exec {_snore_fd}<> <(:); } 2>/dev/null ||
		{
			exec {_snore_fd}<>"${__bashlib_temp_path}/var/fifo"
		}
		if [[ "${seconds}" == "0" ]]; then
			read -u $_snore_fd || :
		else
			read -t "${seconds}" -u $_snore_fd || :
		fi
	}
}

__bl_sleep_init() {
	__bl_temp_path_get --quiet
}

# vim: set ft=sh:
