#
# This is the main file for the Bash RMS client.
#
# To use this client, start by sourcing this file (not executing it).
#
# That will make the various rms_* functions available to your script, which
# you would then use to perform whatever action you had in mind.
#
# Names that start with an underscore indicate that that function or variable
# is intended to be internal and private, and is not part of the public API.
#

declare -A _RMS
_RMS=()
_RMS[lib_dir]="$(dirname "$BASH_SOURCE")"
_RMS[lib_dir]="$(cd "${_RMS[lib_dir]}" ; pwd)"

source "${_RMS[lib_dir]}/core/config.sh"
source "${_RMS[lib_dir]}/core/subshell_warning.sh"
source "${_RMS[lib_dir]}/core/output.sh"
source "${_RMS[lib_dir]}/core/token.sh"
source "${_RMS[lib_dir]}/core/curl.sh"

rms_config clear
rms_token clear

[ "$RMS_SKIP_CONFIG_LOAD" != "1" ] && rms_config load
