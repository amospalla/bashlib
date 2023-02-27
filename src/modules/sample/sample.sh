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
#
# Given a named module <module_name>, we ca:
#     - define <module_name>_load() and <module_name>_init(): the module exports some callable function
#       and also executes initialization code.
#     - define <module_name>_load() only: exports some callable function without the need for initialization.
#     - define <module_name>_init() only: the module is used to export global variables or initialization chore only.

################################################################################
# Loading function:
#     - must be named <module_name>_load().
#     - it is only called once at load time, it can be used only to load 
#       other modules as dependencies and to load final functions.
__bl_my_sample_function_load() {
	# __bl_module_load __bl_some_other_module

	__bl_my_sample_function() {
		echo "I do things"
	}
}

# If <module_name>_init() function exists it is called once at the beginning
# of the program. Used to initialize global variables or other initialization
# program chores (setting up files, environment, etc).
__bl_my_sample_function_init() {
	true
	## Ensure some folder exists
	# mkdir -p /tmp/myfolder
	## Initialize something
	# declare -g some_var
	# some_var=/tmp/myfolder
}
################################################################################

# vim: set ft=sh:
