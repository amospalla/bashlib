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

if [[ "${0}" == */* ]]; then
	. "${0%/*}/../../src/main.sh"  # This file has been invoked including a path
else
	. "../../src/main.sh"  # This file has been invoked from the same path without directory component
fi

__bl_module_load __bl_trap_error
__bl_module_load __bl_echo_color

__bl_run_main "${@}"

# vim: set ft=sh:
