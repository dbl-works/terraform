#!/bin/bash

TEST_DIR="$(pwd)"
declare -a ERRORS=() # initialize empty array

# usage pass the last exit code: check_exit_status $? "$dir" "$cmd"
# will exit with code 1 on error
function check_exit_status() {
  exit_status="$1"
  dir="$2"
  cmd="$3"
  if [ "$exit_status" == 0 ]
  then
    echo "✅  success: $cmd $dir"
  else
    ERRORS+=("❌  failed: $cmd $dir")
  fi
}

# jump into module folder, validate terraform, jump back to test folder
function validate() {
  dir="$1"
  cd "$dir" || return
  terraform init
  check_exit_status $? "$dir" "terraform init"
  terraform validate
  check_exit_status $? "$dir" "terraform validate"
  cd "$TEST_DIR" || { echo "Something went terrible wrong"; exit 1; }
}

# run validation on all terraform modules
for dir in ./*/
do
  if [[ -d "$dir" && "$dir" != *"terraform-tests"* ]]
  then
    validate "$dir"
  fi
done

# print all errors at the end
for error in "${ERRORS[@]}"
do
  echo "$error"
done

# explicitly exit script with 0 or 1
if [[ "${#ERRORS[@]}" != 0 ]]
then
  exit 1
else
  exit 0
fi
