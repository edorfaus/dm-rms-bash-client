#
# Handling of external command output (such as from cURL).
#

declare -A _RMS_output
_RMS_output=()

rms_output() {
	if [ $# -eq 0 -o "$1" = "is" -o "$1" = "put" ]; then
		if [ "${_RMS_output[mode]:-keep}" != "keep" ]; then
			echo "Error: Output mode is not keep." >&2
			return 1
		fi
		if [ "${_RMS_output[output]+isset}" = "" ]; then
			echo "Error: No command output has been kept yet." >&2
			return 1
		fi
		if [ $# -eq 0 ]; then
			if [ -t 1 ]; then
				printf "%s\n" "${_RMS_output[output]}"
			else
				printf "%s" "${_RMS_output[output]}"
			fi
		elif [ "$1" = "is" ]; then
			[ "${_RMS_output[output]}" = "$2" ]
			return $?
		elif ! [[ "$2" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
			echo "Error: Cannot put to an invalid variable name." >&2
			return 1
		else
			eval "$2"'=${_RMS_output[output]}'
		fi
		return $?
	fi
	case "$1" in
		clear) unset _RMS_output[output] ;;
		mode)
			case "$2" in
				keep) unset _RMS_output[mode] ;;
				stdout) _RMS_output[mode]=stdout ;;
				*)
					echo "Error: Unknown output mode: $2" >&2
					return 1
			esac
			unset _RMS_output[output]
			return 0
			;;
		put-mode)
			if ! [[ "$2" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
				echo "Error: Cannot put to an invalid variable name." >&2
				return 1
			fi
			eval "$2"'=${_RMS_output[mode]:-keep}'
			;;
		run)
			shift
			case "${_RMS_output[mode]:-keep}" in
				keep)
					local ret
					_RMS_output[output]="$( "$@" )" ret=$?
					return $ret
					;;
				stdout)
					"$@"
					return $?
					;;
				*)
					echo "Error: Unknown output mode: ${_RMS_output[mode]}" >&2
					return 1
					;;
			esac
			;;
		*)
			echo "Error: Unknown rms_output subcommand: $1" >&2
			return 1
			;;
	esac
}
