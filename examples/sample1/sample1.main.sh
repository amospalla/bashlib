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
    __bl_log debug debug
    __bl_log info info
    __bl_log warning warning
    __bl_log error error
    __bl_log critical critical
    __bl_echo_color green "sleep for 0.5 seconds"
	__bl_sleep 0.5
    false
    true
    echo end
}

# vim: set ft=sh:
