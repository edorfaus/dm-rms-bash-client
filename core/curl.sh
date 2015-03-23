#
# Basic HTTP[S] protocol handling: sending requests to the RMS server
#
# Primarily intended for internal use by the other rms-client functions.
#

rms_config add-settings server client_cert ca_cert
rms_config add-passwords client_cert_password

# _rms_curl [options] [--] <path> [additional curl options]
_rms_curl() {
	local server="${_RMS_config[server]}"
	local has_path=0
	local path=
	local show_error="--show-error"
	local fail="--fail"
	local accept="application/json"
	local c_type="application/json"
	local token=
	local token_was_set=0
	local post_data=

	while [ 0 -eq 0 ]; do
		case "$1" in
			--no-error) show_error= ;;
			--no-fail) fail= ;;

			--post-stdin) post_data="@-" ;;
			--post-file)  post_data="@$2" ; shift ;;

			--accept-json) accept="application/json" ;;
			--accept-text) accept="text/plain" ;;
			--accept-any)  accept="*/*" ;;
			--accept)      accept="$2" ; shift ;;

			--type-json)   c_type="application/json" ;;
			--type-octets) c_type="application/octet-stream" ;;
			--type)        c_type="$2" ; shift ;;
			--no-type)     c_type= ;;

			--no-token) token=     ; token_was_set=1 ;;
			--token)    token="$2" ; token_was_set=1 ; shift ;;

			--server) server="$2" ; shift ;;

			--) shift ; break ;;
			*)
				if [ $has_path -eq 0 ]; then
					path="$1"
					has_path=1
				else
					break
				fi
				;;
		esac
		shift
	done
	if [ $has_path -eq 0 ]; then
		path="$1"
		shift
	fi

	if [ "$path" = "" ]; then
		echo "_rms_curl: The path must be given (as the first parameter)." >&2
		return 1
	fi

	if [ "$server" = "" ]; then
		echo "The server has not been set." >&2
		return 1
	fi

	local ca_cert="${_RMS_config[ca_cert]}"
	local insecure=
	if [ "$ca_cert" = "*" ]; then
		ca_cert=
		insecure="--insecure"
	fi

	local client_cert="${_RMS_config[client_cert]}"
	if [ "$client_cert" != "" ]; then
		if [ "${_RMS_config[client_cert_password]}" != "" ]; then
			client_cert="$client_cert:${_RMS_config[client_cert_password]}"
		fi
	fi

	if [ "$server:0:6}" = "https:" -a "$client_cert" = "" ]; then
		echo "SSL client certificate has not been set for HTTPS server." >&2
		return 1
	fi

	if [ $token_was_set -eq 0 ]; then
		if ! rms_token auto-create ; then
			echo "Error: Failed to auto-create a token." >&2
			return 1
		fi

		rms_token put token

		if [ "$token" = "" ]; then
			echo "Error: Expected a token, but it is not set." >&2
			return 1
		fi
	fi

	rms_output run curl --silent $show_error $fail \
		${client_cert:+"--cert"} ${client_cert:+"$client_cert"} \
		${ca_cert:+"--cacert"} ${ca_cert:+"$ca_cert"} $insecure \
		${accept:+"--header"} ${accept:+"Accept: $accept"} \
		${c_type:+"--header"} ${c_type:+"Content-Type: $c_type"} \
		${token:+"--header"} ${token:+"Authorization: Bearer $token"} \
		${post_data:+"--data-binary"} ${post_data:+"$post_data"} \
		"$@" \
		"$server$path"
}
