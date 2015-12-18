## GPII Preferences Server Dockerfile


This repository is used to build [GPII Preferences Server](http://wiki.gpii.net/w/Architecture_Overview#Preferences_Server) Docker images.


### Environment Variables

The following environment variables can be used to affect the container's behaviour:

* `CLOUDANT_HOST_ADDRESS` - allows the Preferences Server process to reach a Cloudant instance. An full Cloudant URL is expected

* `NODE_ENV` - this should most likely be set to `preferencesServer.production` unless you would like to test more customized deployments

* `PRIME_DB` - if this is the first time the Preferences Server is being deployed then you will want to use `PRIME_DB=yes` so that default [test preferences](https://github.com/GPII/universal/tree/master/testData/preferences) can be modified and uploaded to CouchDB


### Port(s) Exposed

* `8082 TCP`


### Base Docker Image

* [gpii/universal](https://github.com/gpii-ops/docker-universal/)


### Download

    docker pull gpii/preferences-server


#### Bluemix tools

You will need the [Cloud Foundry CLI](https://github.com/cloudfoundry/cli/releases) client and [IBM Containers CLI plugin](https://www.ng.bluemix.net/docs/containers/container_cli_ov.html).

The preferences server can run on Bluemix using a Cloudant database service. 

1. Create a dummy application on Bluemix
2. Create a [Cloudant service](https://console.ng.bluemix.net/catalog/services/cloudant-nosql-db/) from the [Bluemix catalog](https://console.ng.bluemix.net/catalog/)
3. Bind the Cloudant service to the dummy PaaS application
4. The dummy application will have a Cloudant URL in its service credentials. Specify this value for `CLOUDANT_HOST_ADDRESS.` The url has a format of https://user:pass@host.cloudant.com.


#### Build your own image on Bluemix

    cf ic build --rm=true -t preferences-server .

Note: obtain your image id with 
    
    cf ic images
    
#### Run a single `preferences-server` on Bluemix

    
```
cf ic run \
-p 8082:8082 \
--name="preferences_server" \
-e CLOUDANT_HOST_ADDRESS=https://cloudant_user:password@host.cloudant.com \
-e NODE_ENV=preferencesServer.production \
-e PRIME_DB=yes \
<YOUR IMAGE ID>
```

View your container id with

    cf ic ps -a

View logs with

    cf ic logs <CONTAINER ID>
    
#### Bind a public IP to your preference server on Bluemix

Identify an available IP

    cf ic ip list
    
Obtain your container id

    cf ic ps -a

Bind the IP to your container

    cf ic ip bind <IP ADDRESS> <CONTAINER ID>
    
#### Run a container group on Bluemix

Create a container group from your image. You can specify a hostname and domain for the
container group using the Bluemix router instead of a public IP.

```
cf ic group create \
-p 8082:8082 \
--min 2 \                       # Minimum instances in group
--max 10 \                      # Maximum instances in group
-- desired 4 \                  # Desired instances in group
--memory 64 \                   # instance size
--hostname preferences          # hostname will be preferences.mybluemix.net
--domain mybluemix.net
--name <CONTAINER GROUP NAME>  # Specify your own name here
-e CLOUDANT_HOST_ADDRESS=https://cloudant_user:password@host.cloudant.com \
-e NODE_ENV=preferencesServer.production \
-e PRIME_DB=yes \
<YOUR IMAGE ID>
```

Ensure your route is set up

    cf ic route map --hostname preferences --domain mybluemix.net <CONTAINER GROUP NAME>
    
View containers in your group with

    cf ic group instances <CONTAINER GROUP NAME>
    
List container group names with
    
    cf ic group list