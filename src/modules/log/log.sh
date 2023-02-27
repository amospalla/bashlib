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
function __bl_log_load() {
	__bl_module_load __bl_echo_color

	function __bl_log() {
		# log(str: level, str: msg)

		local level

		level="${1}"
		shift

		if [[ "${__bl_log_levels[${level}]}" -ge "${__bl_log_level}" ]]; then
			case "${level}" in
				debug)
					__bl_echo_color cyan "[${level}] ${*}"
					;;
				info)
					__bl_echo_color green "[${level}] ${*}"
					;;
				warning)
					__bl_echo_color yellow "[${level}] ${*}"
					;;
				error)
					__bl_echo_color magenta "[${level}] ${*}"
					;;
				critical)
					__bl_echo_color red "[${level}] ${*}"
					;;
			esac
		fi
	}
}

function __bl_log_init() {
	declare -g -A __bl_log_levels
	declare -g -i __bl_log_level
	__bl_log_levels=([debug]="0" [info]="1" [warning]="2" [error]="3" [critical]="4")
	# Default log level threshold.
	__bl_log_level="2"
}

# vim: set ft=sh:
