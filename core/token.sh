#
# Handling of the bearer token used for authentication.
#

rms_config add-settings token_auto_mode token_auto_create_func token_timeout

rms_token() {
	case "$1" in
		get) echo -n "$_RMS_token" ;;
		clear|set)
			_rms_subshell_warning

			unset _RMS_token _RMS_token_time
			;;&
		clear) ;;
		set)
			if [ "$3" != "" ]; then
				if [[ "$3" =~ ^[0-9]+$ ]]; then
					_RMS_token_time="$3"
				elif [ "$3" = "now" ]; then
					_RMS_token_time="$(date +%s)"
				else
					echo "Error: Invalid token time given: $3" >&2
					return 1
				fi
			fi

			_RMS_token="$2"
			;;
		put)
			if ! [[ "$2" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
				echo "Error: Cannot put to an invalid variable name." >&2
				return 1
			fi
			eval "$2"'=$_RMS_token'
			;;
		create)
			local mode
			rms_output put-mode mode

			${_RMS_config[token_auto_create_func]:-rms_lidp_login}
			local ok=$?

			rms_output mode "$mode"

			return $ok
			;;
		check)
			local mode
			rms_output put-mode mode

			rms_check_token --no-error
			local ok=$?

			rms_output mode "$mode"

			return $ok
			;;
		timed-out)
			# For this command, 0 means timed out or error, 1 means not.
			if [ "$_RMS_token_time" = "" ]; then
				return 0
			fi
			if ! [[ "$_RMS_token_time" =~ ^[0-9]+$ ]]; then
				echo "Error: Invalid token time: $_RMS_token_time" >&2
				return 0
			fi

			local time="$2"
			if [ "$time" = "" ]; then
				time="$(date +%s)"
			fi
			if ! [[ "$time" =~ ^[0-9]+$ ]]; then
				echo "Error: Invalid time: $time" >&2
				return 0
			fi

			local timeout="${_RMS_config[token_timeout]:-30}"
			if ! [[ "$timeout" =~ ^[0-9]+$ ]]; then
				echo "Error: Invalid timeout: $timeout" >&2
				return 0
			fi

			if [ $_RMS_token_time -le $(($time - $timeout)) ]; then
				return 0
			fi
			return 1
			;;
		auto-create)
			_rms_subshell_warning

			local mode="${_RMS_config[token_auto_mode]:-check}"
			case "$mode" in
				never)
					return 0
					;;
				always)
					rms_token create
					return $?
					;;
				empty)
					if [ "$_RMS_token" = "" ]; then
						rms_token create
						return $?
					fi
					return 0
					;;
				check|timeout)
					local time="$(date +%s)"
					if [ "$_RMS_token" != "" ] && ! rms_token timed-out "$time"
					then
						return 0
					fi
					;;&
				check)
					if [ "$_RMS_token" != "" ] && rms_token check
					then
						_RMS_token_time="$time"
						return 0
					fi
					;&
				check|timeout)
					rms_token create
					local ok=$?

					[ $ok -eq 0 ] && _RMS_token_time="$time"

					return $ok
					;;
				*)
					echo "Error: Unknown token auto mode: $mode" >&2
					return 1
					;;
			esac
			;;
		*)
			echo "Error: Unknown rms_token subcommand: $1" >&2
			return 1
			;;
	esac
	return 0
}
