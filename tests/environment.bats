#!/usr/bin/env bats

setup() {
  load "$BATS_PLUGIN_PATH/load.bash"

  # export VAULT_STUB_DEBUG=/dev/tty
}

@test "vault_addr is not set" {
  export BUILDKITE_PIPELINE_SLUG="foo"

  run bash -c "$PWD/hooks/environment && env"
  assert_success
  assert_output --partial "Skipping"

  unset BUILDKITE_PIPELINE_SLUG
}

@test "successful creds retrieval with defaults" {
  export BUILDKITE_PIPELINE_SLUG="foo"
  export BUILDKITE_PLUGIN_VAULT_GCP_CREDS_VAULT_ADDR="http://vault:8200"

  stub vault \
    'read -field=token gcp/impersonated-account/bk-foo/token : echo ya29.c.b0AT7lpjBRmO7ghBEyMV18evd016hq'

  run bash -c "source $PWD/hooks/environment && env | sort"
  assert_success
  assert_output --partial "CLOUDSDK_AUTH_ACCESS_TOKEN=ya29.c.b0AT7lpjBRmO7ghBEyMV18evd016hq"

  unset BUILDKITE_PIPELINE_SLUG
  unset BUILDKITE_PLUGIN_VAULT_GCP_CREDS_VAULT_ADDR

  unset CLOUDSDK_AUTH_ACCESS_TOKEN
}

@test "successful creds retrieval with overrides" {
  export BUILDKITE_PIPELINE_SLUG="foo"
  export BUILDKITE_PLUGIN_VAULT_GCP_CREDS_VAULT_ADDR="http://vault:8200"
  export BUILDKITE_PLUGIN_VAULT_GCP_CREDS_PATH="gcp-creds"
  export BUILDKITE_PLUGIN_VAULT_GCP_CREDS_ACCOUNT_NAME="bar"
  export BUILDKITE_PLUGIN_VAULT_GCP_CREDS_ENV_VAR="GOOGLE_OAUTH_ACCESS_TOKEN"

  stub vault \
    'read -field=token gcp-creds/impersonated-account/bar/token : echo ya29.c.b0AT7lpjBRmO7ghBEyMV18evd016hq'

  run bash -c "source $PWD/hooks/environment && env | sort"
  assert_success
  assert_output --partial "GOOGLE_OAUTH_ACCESS_TOKEN=ya29.c.b0AT7lpjBRmO7ghBEyMV18evd016hq"

  unset BUILDKITE_PIPELINE_SLUG
  unset BUILDKITE_PLUGIN_VAULT_GCP_CREDS_VAULT_ADDR
  unset BUILDKITE_PLUGIN_VAULT_GCP_CREDS_PATH
  unset BUILDKITE_PLUGIN_VAULT_GCP_CREDS_ACCOUNT_NAME
  unset BUILDKITE_PLUGIN_VAULT_GCP_CREDS_ENV_VAR

  unset BUILDKITE_CLOUDSDK_AUTH_ACCESS_TOKEN
}
