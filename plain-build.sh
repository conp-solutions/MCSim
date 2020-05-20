#!/usr/bin/env bash
#
# build.sh, Norbert Manthey, 2020
#
# This script builds MCSim

# This script is expected to host the executables
SCRIPT_DIR=$(dirname $0)
SCRIPT_DIR=$(readlink -e "$SCRIPT_DIR")
declare -r SCRIPT_DIR

# Make sure scripts do not fail half-way through
set +o pipefail

# Fail in case something fails
set -e

declare BIN_PATH="${SCRIPT_DIR}/bin"

# Build coprocessor, and copy coprocessor as well as cfm to bin/
pushd riss
cp scripts/coprocessor-for-modelcounting.sh "$BIN_PATH"
mkdir -p Release
cd Release
cmake -DFLTO=ON -DCMAKE_BUILD_TYPE=Release ..
make coprocessor -j $(nproc)
cp bin/coprocessor "$BIN_PATH"
popd

# Build sharpSAT, and copy it to bin/
pushd sharpSAT

# Compile sharpSAT statically
cp CMakeLists.txt CMakeLists.txt.orig
echo 'SET(CMAKE_EXE_LINKER_FLAGS "-static")' > CMakeLists.txt
cat CMakeLists.txt.orig >> CMakeLists.txt

mkdir -p Release
cd Release/
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j $(nproc)
cp sharpSAT "$BIN_PATH"
cd ..

# Restore original cmake file
cp CMakeLists.txt.orig CMakeLists.txt

popd

# Signal success
exit 0
