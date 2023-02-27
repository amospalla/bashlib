#!/usr/bin/env bash

check() {
	local expected_path
	local obtained_path

	expected_path="$(realpath -m "${1}")"

	__bl_path_canonicalize "${1}"
	obtained_path="${__bl_return}"

	if [[ "${expected_path}" != "${obtained_path}" ]]; then
		echo "Error: Input: '${1}', obtained_path: '${obtained_path}', expected_path:'${expected_path}'."
		exit 1
	# else
	# 	echo "OK: Input: '${1}', obtained_path: '${obtained_path}', expected_path:'${expected_path}'."
	fi
}

main() {
	local -a strings
	local string1 string2 string3 string4 string5

	strings=(foo bar . .. / /. /.. // ///)
	for string1 in "${strings[@]}"; do
		for string2 in "${strings[@]}"; do
			for string3 in "${strings[@]}"; do
				for string4 in "${strings[@]}"; do
					for string5 in "${strings[@]}"; do
						check "${string1}${string2}${string3}${string4}${string5}"
					done
				done
			done
		done
	done
}

main "${@}"

# vim: set ft=sh:
