#
# This file provides a function to push changes to the RMS.
#
rms_push() {
	_rms_subshell_warning
	case "$1" in
		reset) unset _RMS_push_state _RMS_push_actions ;;
		start)
			if [ "$_RMS_push_state" != "" ]; then
				echo "Warning: Previous push was not completed (or reset)." >&2
			fi

			rms_push reset

			_RMS_push_state=started
			;;
		push)
			if [ "$_RMS_push_state" != "started" ]; then
				echo "Error: Can only run a started push without errors." >&2
				return 1
			fi

			_RMS_push_state=pushing

			local request='{"actions": ['"$_RMS_push_actions"$'\n'']}'

			_rms_curl --post-stdin /dots/v1/push <<<"$request"
			local ok=$?

			unset _RMS_push_state _RMS_push_actions

			return $ok
			;;
		create|update|delete|move|screen|unscreen)
			if [ "$_RMS_push_state" = "" ]; then
				rms_push _set_error "Error: Can only add actions to a started push."
				return 1
			elif [ "$_RMS_push_state" != "started" ]; then
				rms_push _set_error "Error: Cannot add actions to a failed push."
				return 1
			fi

			local type="$2"
			local id="$3"

			if [ "$type" = "" -o "$id" = "" ]; then
				rms_push _set_error \
					"Error: The type and id are required for all actions."
				return 1
			fi

			local action="${_RMS_push_actions:+,}"$'\n\t'"{\"$1\": {"
			action="$action"$'\n\t\t''"id": "'"$id\","
			action="$action"$'\n\t\t''"type": "'"$type\""

			case "$1" in
				delete|unscreen)
					# delete <type> <id>
					# unscreen <type> <id>
					;;
				screen)
					# screen <type> <id> <code>
					local code="$4"

					if [ "$code" = "" ]; then
						rms_push _set_error \
							"Error: The code is required for screen."
						return 1
					fi

					action="$action,"$'\n\t\t''"code": "'"$code\""
					;;
				move)
					# move <type> <id> <ref> <from> <to>
					local ref="$4"
					local from="$5"
					local to="$6"

					if [ "$ref" = "" -o "$from" = "" -o "$to" = "" ]; then
						rms_push _set_error \
							"Error: All parameters are required for move."
						return 1
					fi

					action="$action,"$'\n\t\t''"ref": "'"$ref\""
					action="$action,"$'\n\t\t''"from": "'"$from\""
					action="$action,"$'\n\t\t''"to": "'"$to\""
					;;
				create|update)
					# create <type> <id> [<field> <value>]...
					# update <type> <id> [<field> <value>]...
					local fields=

					shift 3
					while [ $# -gt 1 ]; do
						local key="$1"
						local value="$2"
						shift 2

						if [ "$key" = "" ]; then
							rms_push _set_error "Error: Field keys cannot be empty."
							return 1
						fi

						if [ "$value" = "" ]; then
							value="null"
						elif [[ "$value" =~ ^'"'.*'"'$ ]]; then
							: # Value is apparently a quoted string already
						elif ! [[ "$value" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
							value="\"$value\""
						fi

						fields="$fields${fields:+,}"$'\n\t\t\t'"\"$key\": $value"
					done
					if [ $# -gt 0 ]; then
						rms_push _set_error "Error: Field value not specified."
						return 1
					fi

					action="$action,"$'\n\t\t''"fields": {'"$fields"$'\n\t\t''}'
					;;
				*)
					echo "Error in code of push.sh: Unknown action: $1" >&2
					return 1;
					;;
			esac

			action="$action"$'\n\t''}}'

			_RMS_push_actions="$_RMS_push_actions$action"
			;;
		get-current-actions)
			rms_output run printf "[%s\n]" "$_RMS_push_actions"
			;;
		_set_error)
			shift

			if [[ "$_RMS_push_state" == error* ]]; then
				if [ "$_RMS_push_state" = "error!!!!!" ]; then
					# Too many errors, any further ones have been silenced.
					return 1
				fi

				_RMS_push_state="$_RMS_push_state!"

				[ "$*" != "" ] && echo "$@" >&2

				if [ "$_RMS_push_state" = "error!!!!!" ]; then
					echo "Warning: Too many push errors, silencing." >&2
					return 1
				fi

				return 0
			fi

			_RMS_push_state="error"

			[ "$*" != "" ] && echo "$@" >&2

			return 0
			;;
		*)
			rms_push _set_error "Error: Unrecognized subcommand: $1"
			;;
	esac
}

rms_push reset
