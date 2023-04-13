# Vault GCP Credentials Buildkite Plugin

Retrieve time-limited oauth2 access token for an impersonated account from a Hashicorp Vault [GCP Secrets Backend](https://developer.hashicorp.com/vault/docs/secrets/gcp)

The plugin expects a `VAULT_TOKEN` is already set in the environment. The [vault-oidc-auth](https://github.com/planetscale/vault-oidc-auth-buildkite-plugin)
plugin is an ideal companion to use with this plugin.

## Example

Add the following to your `pipeline.yml`:

```yaml
steps:
  - command: ./run_build.sh
    plugins:
      - planetscale/vault-gcp-creds#v1.0.0:
          vault_addr: "https://my-vault-server"   # required
          path: "gcp"                             # optional. default "gcp"
          account_name: "my-pipeline"             # optional. default "bk-$BUILDKITE_PIPELINE_SLUG"
          env_prefix: "BUILDKITE_"                # optional. default "" (prefix to add to CLOUDSDK_AUTH_ACCESS_TOKEN)
```

If authentication is successful the environment variables will be added to the environment:

- `CLOUDSDK_AUTH_ACCESS_TOKEN`

Setting the `env_prefix` property will add a prefix to each environment variable name, eg: `BUILDKITE_CLOUDSDK_AUTH_ACCESS_TOKEN`

## Ephemeral Credentials with vault-oidc-auth

This plugin works best when combined with the [vault-oidc-auth](https://github.com/planetscale/vault-oidc-auth-buildkite-plugin) plugin
to provide short-lived credentials for accessing Vault and GCP. Example:

```yaml
steps:
  - command: ./run_build.sh
    plugins:
      - planetscale/vault-oidc-auth#v1.0.0:
          vault_addr: "https://my-vault-server"
      - planetscale/vault-gcp-creds#v1.0.0:
          vault_addr: "https://my-vault-server"
```

First, the `vault-oidc-auth` plugin uses a short-lived Buildkite OIDC token to authenticate
to Vault and fetch a `VAULT_TOKEN`.

Next, `vault-gcp-creds` uses the `VAULT_TOKEN` to fetch time-limited GCP oauth2 token from Vault.

## Vault Configuration

First, enable the [GCP Secrets Backend](https://developer.hashicorp.com/vault/docs/secret/gcp). A minimal
configuration using environmental GCP credentials might look like the following. See the docs for
full details on configuring the root GCP credentials.

```console
vault secrets enable -path=gcp gcp
```

Then, create a GSA for your pipeline to impersonate through your favorite method and make it available from
Vault by creating and assigning it to account name "bk-my-pipeline":

```console
vault write gcp/impersonated-account/bk-my-pipeline \
    service_account_email="projectAdmin@my-project.iam.gserviceaccount.com" \
    token_scopes="https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/compute" \
    ttl="6h"
```

## Developing

To run the linters:

```shell
docker-compose run --rm lint-shellcheck
docker-compose run --rm lint-plugin
```

To run the tests:

```shell
docker-compose run --rm tests
```

## Contributing

1. Fork the repo
2. Make the changes
3. Run the tests
4. Commit and push your changes
5. Send a pull request
