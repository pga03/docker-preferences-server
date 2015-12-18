#!/bin/sh -e

if [ -z "$NODE_ENV" ] || [ -z "$COUCHDB_HOST_ADDRESS" ]; then
    echo >&2 'Error: Both COUCHDB_HOST_ADDRESS and NODE_ENV environment variables need to be set'
    exit 1
fi

# Modify the following line in the Preferences Server's config to point to a
# real CouchDB instance:
# https://github.com/GPII/universal/blob/ec89640347d0977f3d4642cdd5b91b65896c482f/gpii/node_modules/rawPreferencesServer/configs/production.json#L14
sed -e "s|^ *\"rawPreferencesSourceUrl\": .*$|\"rawPreferencesSourceUrl\": \"http://${COUCHDB_HOST_ADDRESS}:5984/user/%userToken\"|" -i /opt/universal/gpii/node_modules/rawPreferencesServer/configs/production.json

# Bluemix networking has a delay when the container starts. The recommended
# work around is to wait for approx. 30 seconds. We're going to wait till curl
# says the database is reachable.
# Reference: https://developer.ibm.com/answers/questions/183427/calling-out-to-the-internet-from-a-docker-containe/?smartspace=bluemix
/usr/local/bin/wait_for_networking.sh

# Test preferences stored in the GPII Universal repository need to be modified
# before they can be uploaded to CouchDB
if [ -n "$PRIME_DB" ]; then
    mkdir /tmp/modified_preferences
    /usr/local/bin/modify_preferences.sh /opt/universal/testData/preferences /tmp/modified_preferences
    curl -X PUT http://${COUCHDB_HOST_ADDRESS}:5984/user
    npm -g install kanso
    for preference in /tmp/modified_preferences/*.json; do
        kanso upload $preference http://${COUCHDB_HOST_ADDRESS}:5984/user;
    done
    rm -rf /tmp/modified_preferences
    npm -g uninstall kanso
fi

cat >/etc/supervisord.d/preferences_server.ini<<EOF
[program:preferences_server]
command=node /opt/universal/gpii.js
environment=NODE_ENV="${NODE_ENV}"
user=nobody
autorestart=true
redirect_stderr=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
EOF

supervisord -c /etc/supervisord.conf
