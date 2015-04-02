#
# Handling of subshell warnings.
#
# This needs to be the second file loaded, as rms_config requires the function
# defined here to be present before it can be called, which means loading any
# other file (that defines settings) will fail until this file is loaded.
# At the same time, this file cannot be loaded first, as it calls rms_config.
#
_rms_subshell_warning() {
	if [ "${_RMS[load_pid]}" = "$BASHPID" ]; then
		return 0
	fi
	# We are not in the same subshell as the client library was loaded into.
	local warn_mode="${_RMS_config[subshell_warning]:-once-per-subshell}"
	local do_warn=1
	case "$warn_mode" in
		always) ;;
		never) do_warn=0 ;;
		once-per-subshell)
			if [ "${_RMS[subshell_warning_pid]}" = "$BASHPID" ]; then
				do_warn=0
			else
				_RMS[subshell_warning_pid]="$BASHPID"
			fi
			;;
		once-per-subshell-and-below)
			if [ "${_RMS[subshell_warning_done]}" != "" ]; then
				do_warn=0
			else
				# We rely on this being unset by exiting the subshell,
				# and on it being inherited by sub-subshells.
				_RMS[subshell_warning_done]=1
			fi
			;;
		*)
			echo "Error: Unknown subshell warning setting: $warn_mode" >&2
			;;
	esac
	if [ $do_warn -eq 0 ]; then
		return 2
	fi
	echo "Warning: Called in subshell; new values will be lost on exit." >&2
	return 1
}

# Keep the current (sub)shell's PID, to compare against later.
_RMS[load_pid]="$BASHPID"

# This must be after the above function is defined, because rms_config uses it.
rms_config add-settings subshell_warning
