#
# This file provides a function that gets the list of entity types in the RMS.
#
rms_get_entity_types() {
	_rms_curl /dots/v1/get-entity-types
}
