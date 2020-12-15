#!/bin/bash

# This script conforms to the Muse Script API v1, providing
# a 'version',  'applicable <path>', and 'run <path>` operation.

declare -a analyzers
analyzers=("core.DivideZero" "core.uninitialized.Assign" "core.uninitialized.UndefReturn" "unix.Malloc" "core.UndefinedBinaryOperatorResult" "deadcode.DeadStores")

directory=$1
commit=$2
command=$3
SEP=""
run_clang_analyzer() {
    local clangtest=$1
#    lines=$(clang -cc1 -analyze -analyzer-checker="$clangtest" * 2> >(grep -i error/:))
    lines=$(clang -cc1 -analyze -analyzer-checker=core.DivideZero * 2> >(grep -i error\:))
    while read -r i ; do
        file=$(echo $i | cut -d ':' -f 1)
        line=$(echo $i | cut -d ':' -f 2)
        if [[ ! -z "$file" && ! -z "$line" ]] ; then
                echo ${SEP}
                SEP=","
                echo "{"
                echo "\"type\" : \"$pattern\","
                echo "\"message\" : \"Marker found at line $line\","
                echo "\"file\" : \"$file\","
                echo "\"line\" : $line"
                echo "}"
        fi
    done <<< "$lines"
}
if [[ "$command" = "version" ]] ; then
    echo "1"
    exit 0
elif [[ "$command" = "applicable" ]] ; then
    echo "true"
    exit 0
elif [[ "$command" = "run" ]] ; then
    pushd $directory 1>/dev/null 2>&1
    echo "["
    for i in ${analyzers[@]} ; do
        run_clang_analyzer "$i"
    done
    echo "]"
    popd 1>/dev/null 2>&1
else
    exit 1
fi
