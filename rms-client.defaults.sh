#
# This file contains the default settings for the rms-client.
#
# The settings will be loaded from various paths in turn, each file overriding
# the values from the previous files, just as with environment variables.
#
# This means that if you don't want to provide a value for a setting, instead
# falling back to that of previous config files, you must comment out that
# line - setting something to an empty value is not the same as not setting it.
#

# The base URL to the RMS server you want the client to talk to.
server='http://localhost:8083'

# The path to the file containing the client certificate to use with HTTPS.
client_cert=

# The decryption password for the client certificate.
# If this is left blank, then cURL will ask for the password on each request.
# We recommend leaving this blank, for security reasons.
client_cert_password=

# The CA certificate bundle to use to validate the server's certificate.
# If this is set to "*" then the server certificate is not checked.
# If this is left blank, then the default certificate bundle is used.
ca_cert=


# Subshell warning frequency mode.
#
# Being called in a subshell means that changes to the various variables that
# are used by the client will not be persistent - the values will be reset as
# soon as the subshell exits. This is generally not what our users want, yet it
# is easy to cause subshells inadvertently or without knowing it is a problem.
#
# Therefore, various functions in the client detect this and warn about it.
#
# However, since it is possible that the user knows exactly what they're doing,
# and has a good reason to use a subshell anyway despite these problems, this
# setting allows for adjustment of how often these warnings are printed.
#
# Known values:
# - always
#       Always warn about use of subshells whenever it is detected.
# - never
#       Never warn about use of subshells, even when it is detected.
# - once-per-subshell
#       Warn once per detected subshell or sub-subshell. (Default)
# - once-per-subshell-and-below
#       Warn once per detected subshell, but ignore its sub-subshells.
#
subshell_warning=once-per-subshell


# Settings for the Basic IDP create-token service. Note that these must be
# valid for putting into the JSON directly without escaping.
#
# While the string settings are put into double quotes, the array settings are
# not, so they must include the double quotes in the value set here.
#
# Example: bidp_access_codes='"FK","UO"'
# Note how the entire value is in single quotes, to escape the double quotes.

# User ID of the currently effective user.
bidp_user_id=

# User ID of the real user, which can be different from the effective user.
# If this is not set, it defaults to the effective user's ID.
bidp_real_user_id=

# Name of the currently effective user.
bidp_name=

# Roles that the currently effective user has access to.
# This is an array, so to be valid each entry must be put in double quotes.
bidp_roles=

# Access codes that the currently effective user can read. Array, see above.
bidp_access_codes=

# Access codes that the currently effective user can grant. Array, see above.
bidp_access_codes_grant=


# Settings for the Login IDP login service.

# The base URL to the Login IDP server you want the client to talk to.
lidp_server=

# The username to use for logging in to the IDP.
lidp_username=

# The password to use for logging in to the IDP.
# If this is left blank, then cURL will ask for the password on each request.
# We recommend leaving this blank, for security reasons.
lidp_password=
