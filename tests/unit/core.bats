#!/usr/bin/env bats

load test_helper

setup() {
  create_user
  create_test_key $TEST_KEY_NAME
}

teardown() {
  delete_user
  delete_test_keys
}

check_authorized_keys_entry() {
  local KEYFILE_NAME="$1"
  local ENTRY_ID="$2"

  run bash -c "sed -n 's/.*\(NAME=$ENTRY_ID.*\)\ \`.*/\1/p' /home/${TEST_USER}/.ssh/authorized_keys"
  echo "output: "$output
  echo "status: "$status
  assert_output "NAME=$ENTRY_ID"
}

@test "(core) sshcommand create" {
  delete_user

  run bash -c "sshcommand create $TEST_USER ls > /dev/null"
  echo "output: "$output
  echo "status: "$status
  assert_success

  run bash -c "test -f ~${TEST_USER}/.ssh/authorized_keys"
  echo "output: "$output
  echo "status: "$status
  assert_success

  run bash -c "grep -F ls ~${TEST_USER}/.sshcommand"
  echo "output: "$output
  echo "status: "$status
  assert_success
}

@test "(core) sshcommand acl-add" {
  run bash -c "cat ${TEST_KEY_DIR}/${TEST_KEY_NAME}.pub | sshcommand acl-add $TEST_USER user1"
  echo "output: "$output
  echo "status: "$status
  assert_success

  create_test_key new_key
  run bash -c "cat ${TEST_KEY_DIR}/new_key.pub | sshcommand acl-add $TEST_USER user2"
  echo "output: "$output
  echo "status: "$status
  assert_success

  check_authorized_keys_entry $TEST_KEY_NAME user1
  check_authorized_keys_entry new_key user2
}

@test "(core) sshcommand acl-add (bad key failure)" {
  run bash -c "echo test_key | sshcommand acl-add $TEST_USER user1"
  echo "output: "$output
  echo "status: "$status
  assert_failure
}

# # not supported yet
# @test "(core) sshcommand acl-add (with identifier space)" {
#   run bash -c "cat ${TEST_KEY_DIR}/${TEST_KEY_NAME}.pub | sshcommand acl-add $TEST_USER 'broken user'"
#   echo "output: "$output
#   echo "status: "$status
#   assert_success

#   run bash -c "grep 'broken user' ~${TEST_USER}/.ssh/authorized_keys | sed 's/.*\(NAME=.*\) \`.*/\1/'"
#   echo "output: "$output
#   echo "status: "$status
#   assert_output ""
# }

@test "(core) sshcommand acl-remove" {
  run bash -c "cat ${TEST_KEY_DIR}/${TEST_KEY_NAME}.pub | sshcommand acl-add $TEST_USER user1"
  echo "output: "$output
  echo "status: "$status
  assert_success

  run bash -c "grep -F \"$(< ${TEST_KEY_DIR}/${TEST_KEY_NAME}.pub)\" ~${TEST_USER}/.ssh/authorized_keys | grep user1"
  echo "output: "$output
  echo "status: "$status
  assert_success

  run bash -c "sshcommand acl-remove $TEST_USER user1"
  echo "output: "$output
  echo "status: "$status
  assert_success

  run bash -c "grep -F \"$(< ${TEST_KEY_DIR}/${TEST_KEY_NAME}.pub)\" ~${TEST_USER}/.ssh/authorized_keys | grep user1"
  echo "output: "$output
  echo "status: "$status
  assert_failure
}

@test "(core) sshcommand help" {
  run bash -c "sshcommand help | wc -l"
  echo "output: "$output
  echo "status: "$status
  [[ "$output" -ge 4 ]]
}
