#!/usr/bin/env bats

load test_helper

@test "(fn) print-os-id (custom path)" {
  load "/usr/local/bin/sshcommand"

  SSHCOMMAND_OSRELEASE=$BATS_TEST_DIRNAME/fixtures/ubuntu-1404-os-release run "fn-print-os-id"
  echo "output: "$output
  echo "status: "$status
  assert_output "ubuntu"
  assert_success

  SSHCOMMAND_OSRELEASE=$BATS_TEST_DIRNAME/fixtures/debian-jessie-os-release run "fn-print-os-id"
  echo "output: "$output
  echo "status: "$status
  assert_output "debian"
  assert_success

  SSHCOMMAND_OSRELEASE=$BATS_TEST_DIRNAME/fixtures/alpine-32-os-release run "fn-print-os-id"
  echo "output: "$output
  echo "status: "$status
  assert_output "alpine"
  assert_success
}
