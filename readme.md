# Bashlib

Bashlib is a set of bash libraries to help the writing of bash scripts.

# Installation

```bash
git clone https://github.com/amospalla/bashlib/
```

## Requirements
* bash >= 4.2

## Usage:
1 Source the file `src/main.sh`
2 Load modules using `__bl_module_load __bl_<some_module_name>`
3 Use modules `__bl_<some_module_name>`

* Check for code samples under the _examples_ folder.

# Generating a standalone script
Scripts using the library can be exported to a standalone single file. The script script must be written in two separated files, one with that sources Bashlib, loads modules and calls __bl_run_main and other with the final main function (this is how example programs and tests are written).

To generate the file execute the program with the exported variable `__bl_generate_standalone_filename` set to the destination file.

# Using in interactive mode
When using Bashlib on .bashrc file or in interactive mode you must set the variable __bl_interactive_mode. This is to avoid Bashlib setting _set -eu -o pipefail -o errtrace_.

## License
All code found in this repository is licensed under GPL v3 (GNU General Public License v3.0). See LICENSE in the root of the repository for a copy of the license and for more information.
