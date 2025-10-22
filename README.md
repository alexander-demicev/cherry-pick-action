# Rancher Cherry-Pick GitHub Action

Automates backports by opening cherry-pick pull requests on release branches whenever Rancher engineers label an upstream PR with `cherry-pick/<target-branch>`.

[![CI](https://github.com/rancher/cherry-pick-action/actions/workflows/ci.yml/badge.svg)](https://github.com/rancher/cherry-pick-action/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

- **Language:** Go (compiled into a GitHub Action container image)
- **Primary entrypoint:** GitHub Action invoked from `pull_request` and `pull_request_target` events via a reusable workflow
- **Design & testing details:** See [`docs/design.md`](docs/design.md)

## Features

✅ Automatic cherry-pick PR creation based on labels  
✅ Support for multiple target branches  
✅ Configurable conflict handling strategies  
✅ GPG commit signing support  
✅ GitHub Enterprise compatibility  
✅ Dry-run mode for testing  
✅ Comprehensive logging and status reporting  

## Quick Start

### Option 1: Using the Reusable Workflow (Recommended)

Add this workflow to your repository at `.github/workflows/cherry-pick.yml`:

```yaml
name: Cherry-Pick Automation

on:
  pull_request:
    types: [closed, labeled]
  pull_request_target:
    types: [closed, labeled]

jobs:
  cherry-pick:
    uses: rancher/cherry-pick-action/.github/workflows/cherry-pick.yml@v1
    secrets:
      token: ${{ secrets.GITHUB_TOKEN }}
```

### Option 2: Direct Action Usage

For more control, use the action directly in your workflows:

```yaml
name: Cherry-Pick

on:
  pull_request:
    types: [closed, labeled]
  pull_request_target:
    types: [closed, labeled]

permissions:
  contents: write
  pull-requests: write

jobs:
  cherry-pick:
    runs-on: ubuntu-latest
    if: github.event.pull_request.merged == true
    steps:
      - uses: rancher/cherry-pick-action@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

## Usage

### Basic Workflow

1. **Merge a pull request** to your main branch
2. **Add a label** like `cherry-pick/release-v2.8` to the merged PR
3. **The action automatically**:
   - Creates a new branch from the target release branch
   - Cherry-picks the merged commits
   - Opens a new PR against the release branch
   - Copies labels and assignees from the original PR
   - Posts a comment with the result

### Label Format

Labels must match the pattern: `cherry-pick/<branch-name>`

Examples:
- `cherry-pick/release-v2.8`
- `cherry-pick/release/v2.7`
- `cherry-pick/stable`

### Adding Labels

You can add cherry-pick labels:
- **Before merging**: The action will create the backport PR when the PR is merged
- **After merging**: The action will immediately create the backport PR

## Configuration

### Action Inputs

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `github_token` | GitHub token with `contents:write` and `pull-requests:write` | `${{ github.token }}` | No |
| `label_prefix` | Prefix for cherry-pick labels | `cherry-pick/` | No |
| `conflict_strategy` | How to handle conflicts: `fail` or `placeholder-pr` | `fail` | No |
| `target_branches` | Comma/newline-separated list of branches (overrides labels) | `""` | No |
| `dry_run` | Skip git pushes and PR creation | `false` | No |
| `verbose` | Enable verbose logging | `false` | No |
| `log_level` | Logging level: `debug`, `info`, `warn`, `error` | `info` | No |
| `log_format` | Log format: `text` or `json` | `text` | No |
| `github_base_url` | GitHub Enterprise API base URL | `""` | No |
| `github_upload_url` | GitHub Enterprise upload URL | `""` | No |
| `git_user_name` | Git committer name | `Rancher Cherry-Pick Bot` | No |
| `git_user_email` | Git committer email | `no-reply@rancher.com` | No |
| `git_signing_key` | GPG private key for signing commits | `""` | No |
| `git_signing_passphrase` | GPG key passphrase | `""` | No |
| `require_org_membership` | Skip execution if actor is not an org member | `false` | No |

### Action Outputs

| Output | Description |
|--------|-------------|
| `created_prs` | JSON array of created cherry-pick PR URLs |
| `skipped_targets` | JSON array of skipped target branches with reasons |

### Advanced Configuration Examples

#### Multiple Target Branches (No Labels)

```yaml
- uses: rancher/cherry-pick-action@v1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    target_branches: |
      release-v2.8
      release-v2.7
      release-v2.6
```

#### Conflict Handling with Placeholder PRs

```yaml
- uses: rancher/cherry-pick-action@v1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    conflict_strategy: placeholder-pr
```

With `placeholder-pr` strategy, conflicts will create a PR with an empty commit, allowing manual resolution.

#### GitHub Enterprise

```yaml
- uses: rancher/cherry-pick-action@v1
  with:
    github_token: ${{ secrets.GHE_TOKEN }}
    github_base_url: https://github.example.com/api/v3
    github_upload_url: https://github.example.com/api/uploads
```

#### GPG Commit Signing

```yaml
- uses: rancher/cherry-pick-action@v1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    git_signing_key: ${{ secrets.GPG_PRIVATE_KEY }}
    git_signing_passphrase: ${{ secrets.GPG_PASSPHRASE }}
```

**Note:** The GPG key should be base64-encoded or ASCII-armored.

#### Dry Run for Testing

```yaml
- uses: rancher/cherry-pick-action@v1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    dry_run: true
    log_level: debug
```

#### Organization Membership Check

```yaml
- uses: rancher/cherry-pick-action@v1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    require_org_membership: true
```

With `require_org_membership: true`, the action will silently skip execution if the user who triggered it (`GITHUB_ACTOR`) is not a member of the repository owner organization. This is useful for preventing cherry-picks from forked PRs or external contributors.

## Token Requirements & Permissions

- The token must be scoped to the target repository (not a fork) and have permission to push directly to the release branches. Protected branches still need a PAT or GitHub App token with the appropriate bypass rights.

## Optional GPG commit signing

To sign commits created by the action (placeholder commits during conflicts), provide:
- `git_signing_key`: Base64-encoded or ASCII-armored GPG private key
- `git_signing_passphrase`: Passphrase to unlock the key (if required)

The action will import the key, extract the key ID, and configure git to sign all commits in the workspace. Note that GPG must be available in the runner environment.

## Known Limitations

- **Forked pull requests:** The action skips PRs whose head repository differs from the base; create a backport branch in the base repo before labeling.
- **Missing release branches:** Labels pointing to non-existent branches are skipped with guidance; ensure target branches exist ahead of time.
- **Submodules:** Nested git submodules are not fetched or updated during cherry-picks and must be handled manually.
- **Squash merges:** When a PR is squash merged, the action cherry-picks the head commit instead of the merge SHA; ensure the squash commit contains the desired changes.
- **Branch protection:** Protected release branches may block automated pushes; provide a token with the necessary bypass rights or temporarily relax protections.
- **Branch deletion:** The action cannot request `auto_delete_branch`. Enable GitHub's repository setting or another automation if you want cherry-pick branches cleaned up after merge.

These constraints are tracked in the [design notes](docs/design.md#8-weak-points--open-questions) with potential future improvements.

## Troubleshooting

### Cherry-pick PR Not Created

**Symptom:** No cherry-pick PR appears after adding a label.

**Solutions:**
1. Verify the PR is **merged** (not just closed)
2. Check the label format matches `cherry-pick/<branch-name>`
3. Ensure the target branch exists in the repository
4. Review the action logs in the workflow run
5. Check for a comment on the PR explaining why it was skipped

### Permission Denied When Pushing

**Symptom:** Action fails with "permission denied" or "protected branch" error.

**Solutions:**
1. Verify token has `contents:write` permission
2. For protected branches, use a PAT or GitHub App token with bypass rights
3. Check branch protection rules in repository settings

### Conflicts During Cherry-Pick

**Symptom:** Action reports conflicts and doesn't create a PR.

**Solutions:**
1. Use `conflict_strategy: placeholder-pr` to create a PR with an empty commit for manual resolution
2. Manually cherry-pick the changes and create a PR
3. Check the action comment on the original PR for conflict details

### Action Doesn't Trigger

**Symptom:** Action never runs when adding labels.

**Solutions:**
1. Verify workflow file is on the default branch
2. Check workflow uses correct event types: `types: [closed, labeled]`
3. Use `pull_request_target` for forked PR labels (requires `merged == true` check)
4. Review GitHub Actions logs for workflow dispatch issues

### Multiple Cherry-Picks to Same Branch

**Symptom:** Adding the same label twice creates duplicate PRs.

**Solutions:**
The action is idempotent and should detect existing PRs. If duplicates occur:
1. Check for existing cherry-pick branches manually
2. Review action logs for idempotency check failures
3. Report an issue with reproduction steps

### GPG Signing Fails

**Symptom:** Action fails when using `git_signing_key`.

**Solutions:**
1. Ensure key is base64-encoded or ASCII-armored
2. Verify passphrase is correct (if key is encrypted)
3. Check GPG is available in the runner environment
4. Test key locally with `gpg --import` and `git commit -S`

## FAQ

**Q: Can I cherry-pick to multiple branches at once?**  
A: Yes! Add multiple labels (e.g., `cherry-pick/release-v2.8`, `cherry-pick/release-v2.7`) or use the `target_branches` input.

**Q: What happens if the target branch doesn't exist?**  
A: The action skips that target and posts a comment explaining the branch is missing.

**Q: Can I use this with forked PRs?**  
A: The action skips PRs from forks by default. Maintainers must create a branch in the base repository before cherry-picking.

**Q: Does this work with squash merges?**  
A: Yes! The action cherry-picks the head commit for squash merges.

**Q: Can I customize the cherry-pick branch name?**  
A: Not currently. Branches follow the pattern `cherry-pick/<target-branch>/pr-<number>`.

**Q: How do I test the action without creating real PRs?**  
A: Set `dry_run: true` to skip all git pushes and PR creation.

**Q: What if I want to cherry-pick without using labels?**  
A: Use the `target_branches` input to explicitly specify branches.

**Q: What are the `cherry-pick/done/<branch>` labels?**  
A: These labels are automatically added after a successful cherry-pick to prevent duplicate PRs if the same label is re-added. They provide idempotency - if you remove and re-add a cherry-pick label, the action will skip it because the done label already exists.

**Q: How does organization membership checking work?**  
A: With `require_org_membership: true`, the action checks if `GITHUB_ACTOR` (the user who triggered the workflow) is a member of the repository owner organization. If not, the action silently exits without creating cherry-pick PRs. This is useful for preventing automated cherry-picks from forked PRs or external contributors.

**Q: Can I remove done labels to retry a failed cherry-pick?**  
A: Yes! Remove the `cherry-pick/done/<branch>` label, then re-add the `cherry-pick/<branch>` label to retry.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

## License

Apache 2.0 - See [LICENSE](LICENSE) for details.
