#!/usr/bin/env bash

check() {
	local good
	good="$(realpath -m "${1}")"
	__bl_path_canonicalize "${1}"
	if [[ "${good}" != "${__bl_return}" ]]; then
		echo "'${1}' => '${__bl_return}'  deuria ser '${good}'"
		exit 1
	else
		echo "'${1}' => '${__bl_return}' OK"
	fi
}

main() {
	local p1 p2 p3 p4 p5

	for p1 in foo bar . .. / /. /.. // ///; do
		for p2 in "" foo bar . .. / /. /.. // ///; do
			for p3 in "" foo bar . .. / /. /.. // ///; do
				for p4 in "" foo bar . .. / /. /.. // ///; do
					for p5 in "" foo bar . .. / /. /.. // ///; do
						check "${p1}${p2}${p3}${p4}${p5}"
					done
				done
			done
		done
	done
}

main "${@}"

# vim: set ft=sh:
