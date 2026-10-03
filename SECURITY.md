# Security and private data

Forever Macros does not require passwords, API keys, or access tokens. Never add credentials or personal WoW account files to this repository. Do not attach SavedVariables, macros-cache files, or installation receipts to public issues.

The root .gitignore admits the source, tests, selected build tools, and documentation. It excludes local backups and release ZIPs. Releases distribute the ZIP separately.

## Before committing or pushing

Install [Gitleaks](https://github.com/gitleaks/gitleaks), then enable this repository's hooks:

```sh
git config core.hooksPath .githooks
```

Gitleaks must be on PATH. To use a binary elsewhere, set `git config foreverMacros.gitleaksPath /path/to/gitleaks`. The pre-commit hook scans staged changes. The pre-push hook scans all local Git history. Either hook stops if the scanner is missing or finds a possible secret.

GitHub Actions runs the addon tests and scans the full fetched history, working files, and generated ZIP. The workflow uses a pinned scanner release with a checked SHA-256 checksum. Scanner output redacts detected values. These checks reduce disclosure risk but cannot guarantee that every possible secret will be recognized.

## Reporting a problem

Use the repository's private vulnerability reporting feature for security issues. Do not post a working credential in an issue or pull request. Revoke any exposed credential through its provider before sharing a redacted report.
