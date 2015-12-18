#!/bin/bash

# Test preferences stored in the GPII Universal repository need to be modified
# before they can be uploaded to CouchDB
if [ -n "$PRIME_DB" ]; then
    mkdir /tmp/modified_preferences
    /usr/local/bin/modify_preferences.sh /opt/universal/testData/preferences /tmp/modified_preferences
    curl -X PUT ${COUCHDB_HOST_ADDRESS}/user
    npm -g install kanso
    for preference in /tmp/modified_preferences/*.json; do
        kanso upload $preference ${COUCHDB_HOST_ADDRESS}/user;
    done
    rm -rf /tmp/modified_preferences
    npm -g uninstall kanso
fi

exit 0
