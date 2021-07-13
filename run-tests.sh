#!/bin/bash

declare -a FAILED_TESTS=() # initialize empty array

# use a subshell so we can capture the exit code, without exiting this script
# if any subscript exists
for file in ./tests/*.sh
do
  if test -f "$file"
  then
    result=$(source "$file")
    if [[ "$?" == 1 ]]
    then
      FAILED_TESTS+=("👉  failures in: $file")
    fi
    echo "$result" # print out result from subscript
  fi
done

# print all failed files at the end
for failure in "${FAILED_TESTS[@]}"
do
  echo "$failure"
done

# CI needs an exit code of 1 or 0
if [[ "${#FAILED_TESTS[@]}" != 0 ]]
then
  exit 1
else
  exit 0
fi
