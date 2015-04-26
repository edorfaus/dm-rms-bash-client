#
# This file provides a function that checks if the RMS is online.
#
rms_ping() {
	local no_error=
	[ "$1" = "--no-error" ] && no_error=1

	rms_output mode keep

	_rms_curl ${no_error:+--no-error} --accept-text --no-token /dots/v1/ping \
		&& rms_output is "pong"
}
