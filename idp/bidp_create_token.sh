#
# This file provides a function that creates a token using the Basic IDP.
#
# The created token will be put into the "token" setting using rms_config.
#
# Note that the settings must already be valid for the JSON request, meaning
# this code does not do any escaping or similar, just inserts the string as-is
# into the JSON string. For the string settings, the given value is wrapped in
# double quotes, but this is not done for the array settings - which means they
# have to include the double quotes, but can contain more than one item.
#

rms_config add-settings bidp_user_id bidp_real_user_id bidp_name bidp_roles
rms_config add-settings bidp_access_codes bidp_access_codes_grant

# rms_bidp_create_token [user_id [name [roles [access [grant [real_user_id]]]]]]
rms_bidp_create_token() {
	local user_id="$1"
	local name="${2:-${_RMS_config[bidp_name]}}"
	local roles="${3:-${_RMS_config[bidp_roles]}}"
	local access="${4:-${_RMS_config[bidp_access_codes]}}"
	local grant="${5:-${_RMS_config[bidp_access_codes_grant]}}"
	local real_user_id="${6:-$user_id}"
	user_id="${user_id:-${_RMS_config[bidp_user_id]}}"
	real_user_id="${real_user_id:-${_RMS_config[bidp_real_user_id]}}"
	real_user_id="${real_user_id:-$user_id}"

	request='{
		"realUserId": "'"$real_user_id"'",
		"effectiveUserId": "'"$user_id"'",
		"name": "'"$name"'",
		"roles": ['"$roles"'],
		"accessCodes": ['"$access"'],
		"accessCodesGrant": ['"$grant"']
	}'

	rms_output mode keep

	_rms_curl --post-stdin --accept-text --no-token /dots/v1/create-token \
		<<<"$request"
	local result=$?

	if [ $result -eq 0 ]; then
		local token=
		rms_output put token
		if [ "$token" = "" ]; then
			return 1
		fi
		rms_token set "$token"
	fi

	return $result
}
