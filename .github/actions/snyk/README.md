# Snyk Security Scan Action

This composite action handles authentication with Snyk, runs a dependency vulnerability scan (`snyk test`), generates a GitHub Job Summary, and optionally uploads results as SARIF for GitHub Code Scanning and as build artifacts.

## Description

1.  **Authenticates** the Snyk CLI using a token retrieved from environment variables.
2.  **Scans** the project dependencies for vulnerabilities and license issues.
3.  **Reports** results:
    *   Generates a Markdown table in the GitHub Actions Job Summary.
    *   Produces a JSON report (`snyk-report.json`).
    *   Produces a SARIF file (`snyk-deps.sarif`) for GitHub Security integration.
4.  **Uploads** artifacts (JSON and SARIF) if enabled.

## Prerequisites

*   The runner must have the **Snyk CLI** installed.
*   The caller workflow must set the environment variable `ACTION_SECRETS_SNYK_TOKEN` (typically via AWS Secrets Manager) before calling this action.

## Inputs

| Input | Description | Required | Default |
| :--- | :--- | :--- | :--- |
| `secret` | The AWS Secrets Manager secret ID where the Snyk token is stored. (Used for reference/logging, actual auth uses env var). | No | |
| `path` | The file path or directory to run the Snyk scan against. | No | `.` |
| `severity_threshold` | The minimum severity threshold to report (e.g., `low`, `medium`, `high`, `critical`). | No | `low` |
| `upload_artifacts` | Boolean flag (`true`/`false`) to upload scan results (JSON/SARIF) as workflow artifacts. | No | `false` |

## Outputs

| Output | Description |
| :--- | :--- |
| `token` | The Snyk token fetched during the process (if exported by internal steps). |

## Usage Example

```yaml
jobs:
  security_scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # 1. Fetch Secrets (Example using AWS Secrets Manager)
      # Ensure the secret contains a key named 'SNYK_TOKEN' which maps to env.ACTION_SECRETS_SNYK_TOKEN
      - name: Fetch Secrets
        uses: aws-actions/aws-secretsmanager-get-secrets@v2
        with:
          secret-ids: my/snyk/secret
          parse-json-secrets: true

      # 2. Run Snyk Action
      - name: Run Snyk Scan
        uses: ./.github/actions/snyk
        with:
          path: '.'
          severity_threshold: 'medium'
          upload_artifacts: true
```

## Artifacts Produced

If `upload_artifacts` is set to `true`, the following files are uploaded as an artifact named `snyk-results`:

*   `snyk-report.json`: Full raw JSON output from Snyk.
*   `snyk-deps.sarif`: SARIF format for dependency vulnerabilities.
*   `snyk-code.sarif`: SARIF format for static code analysis (if enabled in the action).

## Job Summary

The action automatically appends a summary table to the GitHub Actions run summary, displaying:
*   Vulnerabilities (Package, Severity)
*   License Issues (License Type, Severity)

## Notes

*   The action uses `|| true` on the scan command to prevent the workflow from failing immediately if vulnerabilities are found. This allows the report to be generated and uploaded.
*   To enforce build failure on high severity issues, modify the `snyk test` command in `action.yaml` to remove `|| true`.
