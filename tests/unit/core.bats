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

  run bash -c "sed -n 's/.*\(NAME=\\\\\"${ENTRY_ID}\\\\\"\).*/\1/p' /home/${TEST_USER}/.ssh/authorized_keys"
  echo "entry: " $(grep $ENTRY_ID /home/${TEST_USER}/.ssh/authorized_keys)
  echo "output: "$output
  echo "status: "$status
  assert_output "NAME=\\\"$ENTRY_ID\\\""
}

check_custom_allowed_keys() {
  local ALLOWED_KEYS="$1"

  run bash -c "grep ${ALLOWED_KEYS} /home/${TEST_USER}/.ssh/authorized_keys"
  echo "entry: " $(cat /home/${TEST_USER}/.ssh/authorized_keys)
  echo "output: "$output
  echo "status: "$status
  assert_success
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

@test "(core) sshcommand acl-add (as argument)" {
  run bash -c "sshcommand acl-add $TEST_USER user1 ${TEST_KEY_DIR}/${TEST_KEY_NAME}.pub"
  echo "output: "$output
  echo "status: "$status
  assert_success

  create_test_key new_key
  run bash -c "sshcommand acl-add $TEST_USER user2 ${TEST_KEY_DIR}/new_key.pub"
  echo "output: "$output
  echo "status: "$status
  assert_success

  check_authorized_keys_entry $TEST_KEY_NAME user1
  check_authorized_keys_entry new_key user2
}

@test "(core) sshcommand acl-add (custom allowed keys)" {
  run bash -c "cat ${TEST_KEY_DIR}/${TEST_KEY_NAME}.pub | SSHCOMMAND_ALLOWED_KEYS=keys-user1 sshcommand acl-add $TEST_USER user1"
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
  check_custom_allowed_keys keys-user1
  check_custom_allowed_keys no-agent-forwarding,no-user-rc,no-X11-forwarding,no-port-forwarding
}

@test "(core) sshcommand acl-add (bad key failure)" {
  run bash -c "echo test_key | sshcommand acl-add $TEST_USER user1"
  echo "output: "$output
  echo "status: "$status
  assert_failure
}

@test "(core) sshcommand acl-add (with identifier space)" {
  run bash -c "cat ${TEST_KEY_DIR}/${TEST_KEY_NAME}.pub | sshcommand acl-add $TEST_USER 'broken user'"
  echo "output: "$output
  echo "status: "$status
  assert_success

  check_authorized_keys_entry $TEST_KEY_NAME 'broken user'
}

@test "(core) sshcommand acl-add (duplicate key)" {
  run bash -c "cat ${TEST_KEY_DIR}/${TEST_KEY_NAME}.pub | sshcommand acl-add $TEST_USER user1"
  echo "output: "$output
  echo "status: "$status

  run bash -c "cat ${TEST_KEY_DIR}/${TEST_KEY_NAME}.pub | sshcommand acl-add $TEST_USER user1"
  echo "output: "$output
  echo "status: "$status

  assert_failure
  check_authorized_keys_entry $TEST_KEY_NAME user1
}

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
