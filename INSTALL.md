# Build

## Build in Docker

To create a package that can be used to run the tool on optil.io, the following
script should be executed from the root of the repository. The build requirement
is a running docker setup.

./docker/run_in_container.sh \
    docker/Dockerfile \
    ./scripts/create-optilio.sh

The resulting tar.gz file contains the relevant tools to run the model counter.

## Plain Build

To just build the tool, run the following script from the root of the
repository. The script requires the build dependencies for the tools that are
used in this tool: coprocessor and sharpSAT.

./plain-build.sh
