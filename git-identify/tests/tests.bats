#!/usr/bin/env bats

load test_helper

#
# Parsing
#
@test "Parses identities without error" {
   move_to_random_repo
   run git identify

   [ "$status" -eq 0 ]
}

# TODO: This probably shouldn't work like this..
@test "Doesn't throw if an identity is unfinished but end of file" {
  create_identities_file "$(cat <<EOF
[identity:test]
  name = Connor Atherton
EOF)"

  move_to_random_repo
  run git identify

  [ "$status" -eq 0 ]
}

@test "knows when an identity is incomplete and throws if new identity started" {
  create_identities_file "$(cat <<EOF
[identity:test2]

[identity:test]
  name = Connor Atherton
EOF)"

  move_to_random_repo
  run git identify

  [ "$status" -eq 1 ]
}

@test "errors if an identity decleration is left blank" {
  create_identities_file "$(cat <<EOF
[identity:test2]

[identity:test]
  name = Connor Atherton
EOF)"

  move_to_random_repo
  run git identify

  [ "$status" -eq 1 ]
  # [[ "$output" =~ "Malformed .git_identities file" ]
}

@test "It strips whitespace" {
  create_identities_file "$(cat <<EOF
    [identity:test]
name=            Connor Atherton
        email     = connor@email.com
EOF)"

  move_to_random_repo
  run git identify

  [ "$status" -eq 0 ]
}

@test "Doesn't care when an identity has no rules" {
  create_identities_file ""
  move_to_random_repo
  run git identify

  [ "$status" -eq 0 ]
}

#
# Matching
#
@test "Works for both identities" {
  create_git_repo "test"
  append_identity_rule "work" "test"
  run git identify

  [ "$status" -eq 0 ]
  [[ "$output" =~ "<david@wilson.com>" ]]
}

@test "Works for globs in pathnames" {
  # TODO write this test
  # create_git_repo "test"
  # append_tilde_identity_rule "personal" "test"
  # run git identify
  # debug_test

  # [ "$status" -eq 0 ]
  # [[ "$output" =~ "<john@smith.com>" ]]
}

