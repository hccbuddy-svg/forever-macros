# Security and private data

Forever Macros does not require passwords, API keys, or access tokens. Never add credentials or personal WoW account files to this repository. Do not attach SavedVariables, macros-cache files, or installation receipts to public issues.

The root .gitignore admits the source, tests, selected build tools, and documentation. It excludes local backups and release ZIPs. Releases distribute the ZIP separately.

Workshop imports use a bounded data format containing class, approved spell keys and fixed options. They do not call loadstring, deserialize Lua tables or execute macros. Import opens a draft or profile preview. Unknown versions, foreign classes, duplicate profile slots and oversized strings are rejected. Raw scripts and third-party encoded import strings are not accepted.

Drafts, sequence history and build profiles stay in per-character SavedVariables. Share strings omit character identity and bindings. The Copy macro button copies generated text only. Exporting or publishing personal SavedVariables remains outside the release process.

The Coach bundles dated public talent data and source links. It makes no network requests, downloads or external account connections. Its talent reader uses committed public trait data outside combat, checks spell identity and layout, and stops personalized guidance when a field is restricted, missing or incompatible. It never spends, commits or resets talents. The reference bar does not read cooldowns, resources, auras or targets, infer restricted combat values, or execute actions. Plan selections and bar settings stay in character SavedVariables. Copying a guide link contains no character data.

Bag tools store frame positions and an enabled preference per character. Sorting requires a click on Sort and calls the native equipped-bag sorter. It never runs from inventory events or resumes a blocked request after combat. Item locks, cursor contents and combat are checked before the request. The addon does not pick up items through a cursor loop, clear the cursor, change bag exclusions, sort the bank, sell, delete or mail items. Reverse direction changes only the native preference after a separate click. The local installer writes addon files, not inventory or SavedVariables files.

## Before committing or pushing

Install [Gitleaks](https://github.com/gitleaks/gitleaks), then enable this repository's hooks:

```sh
git config core.hooksPath .githooks
```

Gitleaks must be on PATH. To use a binary elsewhere, set `git config foreverMacros.gitleaksPath /path/to/gitleaks`. The pre-commit hook scans staged changes. The pre-push hook scans all local Git history. Either hook stops if the scanner is missing or finds a possible secret.

GitHub Actions runs the addon tests and scans the full fetched history, working files, and generated ZIP. The workflow uses a pinned scanner release with a checked SHA-256 checksum. Scanner output redacts detected values. These checks reduce disclosure risk but cannot guarantee that every possible secret will be recognized.

## Reporting a problem

Use the repository's private vulnerability reporting feature for security issues. Do not post a working credential in an issue or pull request. Revoke any exposed credential through its provider before sharing a redacted report.
