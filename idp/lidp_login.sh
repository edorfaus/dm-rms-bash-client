#
# This file provides a function that creates a token using the Login IDP.
#
# The created token will be put into the "token" setting using rms_config.
#

rms_config add-settings lidp_server lidp_username
rms_config add-passwords lidp_password

# rms_lidp_login [username [password]]
rms_lidp_login() {
	local username="${1:-${_RMS_config[lidp_username]}}"
	local password="${2:-${_RMS_config[lidp_password]}}"
	local server="${_RMS_config[lidp_server]}"

	if [ "$server" = "" ]; then
		echo "The Login IDP server has not been configured." >&2
		return 1
	fi

	if [ "$username" = "" ]; then
		echo "The Login IDP username has not been provided." >&2
		return 1
	fi

	local userpass="$username${password:+:}$password"

	rms_output mode keep

	_rms_curl --server "$server" --post-stdin --accept-text --no-token \
		-- /idp/login --basic --user "$userpass" <<<""
	local result=$?

	if [ $result -eq 0 ]; then
		local token=
		rms_output put token
		if [ "$token" == "" ]; then
			return 1
		fi
		rms_token set "$token"
	fi

	return $result
}
