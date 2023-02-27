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
__bl_color_load() {
	__bl_color_raw() {
		# Return code to print a color.
		#
		# "Available: white, black, red, green, yellow, blue, magenta, cyan."
		# "Prefixes: bold, dim, underline, blink, reverse, hidden"

		local mode number
		case "${1:-}" in
			*bold*)      mode=1 ;;
			*dim*)       mode=2 ;;
			*underline*) mode=4 ;;
			*blink*)     mode=5 ;;
			*reverse*)   mode=7 ;;
			*hidden*)    mode=8 ;;
			*)           mode=0 ;;
		esac
		case "${1:-}" in
			*white*)   number="37" ;;
			*black*)   number="30" ;;
			*red*)     number="31" ;;
			*green*)   number="32" ;;
			*yellow*)  number="33" ;;
			*blue*)    number="34" ;;
			*magenta*) number="35" ;;
			*cyan*)    number="36" ;;
			*)         number="0" ;;
		esac
		printf -v __bl_return "%s" "\e[${mode};${number}m"
	}

	__bl_color() {
		# "Usage: __bl_color [-f] [color]"
		#
		# -f: force even if stdout is not available
		#
		# "Available: white, black, red, green, yellow, blue, magenta, cyan."
		# "Prefixes: bold, dim, underline, blink, reverse, hidden"
		if [[ "${1:-None}" == "-f" ]]; then
			shift
		elif ! [[ -t 1 ]]; then
			# Set color only if stdout file descriptor is opened or it is forced.
			return
		fi

		__bl_color_raw "${1:-}"

		printf "${__bl_return}"
	}
}

################################################################################
__bl_printf_or_echo_color_load() {
	__bl_printf_or_echo_color() {
		local mode
		local force
		local color

		mode="${1}"
		shift

		if [[ "${1:-}" == '-f' ]]; then
			shift
			force="-f"
		fi

		color="${1}"
		shift
		__bl_color ${force:-} "${color}"
		"${mode}" "${@}"
		__bl_color
	}
}

################################################################################
__bl_printf_color_load() {
    __bl_module_load __bl_color
    __bl_module_load __bl_printf_or_echo_color

	__bl_printf_color() {
		__bl_printf_or_echo_color printf "${@}"
	}
}

################################################################################
__bl_echo_color_load() {
    __bl_module_load __bl_color
    __bl_module_load __bl_printf_or_echo_color

	__bl_echo_color() {
		__bl_printf_or_echo_color echo "${@}"
	}
}

# vim: set ft=sh:
