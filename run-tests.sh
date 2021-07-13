#!/bin/bash

declare -a FAILED_TESTS=() # initialize empty array

# use a subshell so we can capture the exit code, without exiting this script
# if any subscript exists
for file in ./terraform-tests/*.sh
do
  echo "$file"
  if test -f "$file"
  then
    result=$(source "$file")
    if [[ "$?" == 1 ]]
    then
      FAILED_TESTS+=("👉  failures in: $file")
    fi
    echo "$result"
  fi
done

# print all filed files at the end
for failure in "${FAILED_TESTS[@]}"
do
  echo "$failure"
done

# CI needs a exit code 1 or 0
if [[ "${#FAILED_TESTS[@]}" != 0 ]]
then
  exit 1
else
  exit 0
fi
