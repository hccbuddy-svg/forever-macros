# CI

CI runs only on self-hosted runners. This repository does not use GitHub-hosted runners.

Register one runner on the Mac mini and one on the Windows PC for this repository (`hccbuddy-svg/forever-macros`). A runner registered on another repository is not used here. GitHub's default labels are enough: `self-hosted` and `macOS` on the Mac, `self-hosted` and `Windows` on the PC. No custom label is required.

Until those runners are online, the matching job stays queued.

Before registering a runner, refuse fork pull request workflows in repository settings. This repository is public, so under Settings → Actions → General require approval for all outside collaborators, and do not approve those runs. A fork can edit the workflow file. The workflow also skips a pull request whose head repository is not this one. That skip is not a substitute for the setting.

Install Python 3.12 for the runner account. `python` must be on PATH, and `python -m pip` must be allowed to install packages. The workflow does not use `actions/setup-python`. On macOS that action only accepts Python installed in `/Users/runner/hostedtoolcache`, which takes a one-time privileged setup. On Windows it needs an administrator account and 7-Zip.

The Mac job downloads the darwin_arm64 Gitleaks build, so that runner must be Apple silicon. The Windows job downloads the windows_x64 build. Both runners need Git on PATH.
