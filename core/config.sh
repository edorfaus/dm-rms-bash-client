#
# Configuration handling: load from file(s), read from console, set to value...
#
# This needs to be the first file loaded, as most of the others depend on its
# functionality during load (to do things like define their settings).
#

declare -A _RMS_settings
_RMS_settings=()
declare -A _RMS_config
_RMS_config=()

rms_config() {
	case "$1" in
		load)
			shift
			if [ $# -eq 0 ]; then
				# No files given: use a default list of files.
				set -- \
					"${_RMS[lib_dir]}/rms-client.defaults.sh" \
					"/etc/rms-client.sh" \
					"$HOME/.config/rms-client.sh" \
					"rms-client.settings.sh"
			fi
			local file
			for file ; do
				if ! [ -r "$file" ]; then
					continue
				fi
				eval "$(
					for setting in ${!_RMS_settings[@]} ; do
						eval "$setting"'=${_RMS_config[$setting]}'
					done
					source "$file" >&2
					for setting in ${!_RMS_settings[@]} ; do
						value="${!setting}"
						if [ "$value" = "" ]; then
							echo "unset _RMS_config[$setting]"
						else
							echo "_RMS_config[$setting]='${value//"'"/"'\\''"}'"
						fi
					done
				)"
			done
			;;
		read|set)
			local setting
			if [ "${_RMS_settings[$2]:+isset}" = "" ]; then
				echo "Unknown setting: $2" >&2
				return 1
			fi
			if [ "$1" = "read" ]; then
				local is_pw=${_RMS_settings[$2]}
				[ $is_pw -eq 0 ] && is_pw=
				read -p "New value for $2> " -r ${is_pw:+-s} "_RMS_config[$2]"
				echo
			elif [ "$3" = "" ]; then
				unset _RMS_config[$2]
			else
				_RMS_config[$2]=$3
			fi
			;;
		clear)
			_RMS_config=()
			;;
		add-settings|add-passwords)
			local type=0
			[ "$1" = "add-passwords" ] && type=1
			shift
			local setting
			for setting ; do
				if [ "${_RMS_settings[$setting]:+1}" != "" ]; then
					echo "Warning: duplicate setting: $setting" >&2
					[ $type -ne 0 ] && _RMS_settings[$setting]=$type
				else
					_RMS_settings[$setting]=$type
				fi
			done
			;;
		*)
			echo "Invalid config subcommand: $1" >&2
			return 1
			;;
	esac
	return 0
}
