#!/bin/bash

# Bluemix networking has a delay when the container starts. The recommended
# work around is to wait for approx. 30 seconds. We're going to wait till curl
# says the database is reachable.
# Reference: https://developer.ibm.com/answers/questions/183427/calling-out-to-the-internet-from-a-docker-containe/?smartspace=bluemix

networking_up=0

while [ $networking_up -ne 1 ]; do

  echo "checking database connectiong..."
  curl -X GET ${COUCHDB_HOST_ADDRESS}
  exit_cd=$?

  if [ $exit_cd -eq 0 ]; then
    networking_up=1  # the network is up if curl is successful
  fi
  sleep 1
done
exit 0