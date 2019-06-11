# Containerized IOHanalyzer hosted through ShinyProxy

This example is similar to the example 'standalone ShinyProxy with a docker engine', with one exception:
ShinyProxy runs in a container itself, in the same container manager (i.e. docker engine) that also hosts
the containers for the users' Shiny apps.

## Requirement

The only requirement is a working docker system. Please consult the docker official documentation to see how to install docker on your server platform: https://docs.docker.com/install/

## How to deploy IOHanalyzer over the server

1. On the server you would like to deploy IOHanalyzer, please download or clone this repository:
``git clone git@github.com:IOHprofiler/IOHanalyzer-docker.git``

2. `cd IOHanalyzer-docker`
3. Create a docker network that ShinyProxy will use to communicate with the Shiny containers.
``sudo docker network create ioh-net``

4. Run the following command to build the ShinyProxy image:
``sudo docker build . -t iohanalyzer``

5. Run the following command to launch the ShinyProxy container:
``sudo docker run -d -v /var/run/docker.sock:/var/run/docker.sock --net ioh-net -p 80:8080 iohanalyzer``

## Notes on the configuration

* ShinyProxy will listen for HTTP traffic on port `80`.
* The custom bridge network `ioh-net` is needed to allow the containers to access each other using the container ID as hostname.
