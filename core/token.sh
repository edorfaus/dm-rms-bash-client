#
# Handling of the bearer token used for authentication.
#
rms_token() {
	case "$1" in
		clear) _rms_subshell_warning ; unset _RMS_token ;;
		set) _rms_subshell_warning ; _RMS_token="$2" ;;
		get) echo -n "$_RMS_token" ;;
		put)
			if ! [[ "$2" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
				echo "Error: Cannot put to an invalid variable name." >&2
				return 1
			fi
			eval "$2"'=$_RMS_token'
			;;
		*)
			echo "Error: Unknown rms_token subcommand: $1" >&2
			return 1
			;;
	esac
	return 0
}
