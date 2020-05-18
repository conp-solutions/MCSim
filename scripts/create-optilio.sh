#!/usr/bin/env bash
#
# create-optilio.sh, Norbert Manthey, 2020
#
# This script builds MCSim versionized for optilio, which expects a tar ball and
# in the root directory a script/binary with the same name as the tar ball.

# This script is expected to host the executables
SCRIPT_DIR=$(dirname $0)
SCRIPT_DIR=$(readlink -e "$SCRIPT_DIR")
declare -r SCRIPT_DIR

# Make sure scripts do not fail half-way through
set +o pipefail

# Copy the resulting file here
CURRENT_DIR="${PWD}"

# Make sure we clean up
trap 'rm -rf $TMPD' EXIT
TMPD=$(mktemp -d)

# Get version string
pushd "$SCRIPT_DIR"
VERSION_STRING=$(git describe --always)
popd

# create the project directory
pushd "$TMPD"

# Clone current state
git clone "$SCRIPT_DIR"/.. MCSim

# Build the tool, using a versionized link
cd MCSim
# Update submodules
git submodule update --init --recursive
ln -sf MCSim.sh MCSim-"$VERSION_STRING".sh
./plain-build.sh

# Create a versionized tar ball
tar czf MCSim-"$VERSION_STRING".sh.tar.gz LICENSE* README* bin MCSim*.sh

# Copy the resulting tar ball
cp MCSim-"$VERSION_STRING".sh.tar.gz "$CURRENT_DIR"

popd

# Signal success
exit 0
