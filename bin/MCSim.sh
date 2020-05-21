#!/usr/bin/env bash
#
# MCSim, Norbert Manthey, 2020
#
# This script connects coprocessor and sharpSAT to form a model counter

# This directory is expected to host the executables
SCRIPT_DIR=$(dirname $(readlink -e $0))
SCRIPT_DIR=$(readlink -e "$SCRIPT_DIR")
declare -r SCRIPT_DIR

# Make sure scripts do not fail half-way through
set +o pipefail

# This function prints the header for the tool
print_header ()
{
   cat << EOF
c MCSim, Norbert Manthey, 2020
c
c combining propositional simplifier with model counter
c
EOF
}

# This function prints the usage of the tool
usage ()
{
   cat << EOF
$0 <input>

MCSim.sh counts the number of models in a (weithed) propositional formula.

 <input> ... propositional (weighted) formula, either plain or gzipped
EOF
}

# Check presence of relevant tools
for tool in coprocessor-for-modelcounting.sh coprocessor sharpSAT
do
    if ! command -v "$SCRIPT_DIR/$tool" &> /dev/null
    then
        echo "Failed to find tool $tool in directory $SCRIPT_DIR"
        echo "Abort"
        usage
        exit 1
    fi
done

INPUT="$1"

TMPDIR=""

# This function is always called on EXIT
cleanup ()
{
    # Print log to stderr
    # cat "$TMPDIR"/cfm-output.log 1>&2
    
    # Clean up temporary directory
    [ -d "$TMPDIR" ] && rm -rf "$TMPDIR"
}

print_header

# Get a temporary directory, and make sure we clean up
trap cleanup EXIT
TMPDIR="$(mktemp -d)"

# Check for parameter
if [ ! -r "$INPUT" ]
then
    echo "Failed to read input file $INPUT"
    echo "Try to read from stdin"
    cat /dev/stdin > "$TMPDIR"/input.cnf
    INPUT="$TMPDIR"/input.cnf
fi

# Activate THP, in case binaries support it
export GLIBC_THP_ALWAYS=1

# Execute tool combination, log to cfm-output.log, and before writing to stdout,
# prepend everything with a 'c ' to turn it into a comment
echo "c starting model counter with simplifier with logging ..."
"$SCRIPT_DIR"/coprocessor-for-modelcounting.sh \
    -F \
    -c "$SCRIPT_DIR"/coprocessor "$INPUT" \
    "$SCRIPT_DIR"/sharpSAT |& tee "$TMPDIR"/cfm-output.log | sed -e 's/^/c /' 
# Copy exit codes
EXITCODE_ARRAY=("${PIPESTATUS[@]}")
CFM_STATUS="${EXITCODE_ARRAY[0]}"
echo "c done"
echo "c status of cfm: $CFM_STATUS"

# Check exit code
if [ "$CFM_STATUS" -ne 0 ] && [ "$CFM_STATUS" -ne 10 ] && [ "$CFM_STATUS" -ne 20 ]
then
    echo "error: cfm's status code: $CFM_STATUS"
    exit "$CFM_STATUS"
fi

# Extract solution from file
SOLUTIONS=$(grep -A 1 '^# solutions' "$TMPDIR"/cfm-output.log | tail -n 1)

# Print number of solutions for model counting competition
echo "c"
echo "s mc $SOLUTIONS"

# Signal success
exit 0
