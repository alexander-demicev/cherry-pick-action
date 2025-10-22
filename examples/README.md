# Example Workflows

This directory contains example workflow files demonstrating various configurations of the Cherry-Pick Action.

## Available Examples

### 1. [Basic Usage](basic-usage.yml)
The simplest setup for automated cherry-picks. Perfect for getting started quickly.

**Use this if:**
- You want a simple, no-frills setup
- You're using GitHub.com (not Enterprise)
- You don't need special conflict handling
- You want to use default settings

**Features:**
- Label-based triggering (`cherry-pick/<branch>`)
- Automatic PR creation on merge
- Works with default GitHub token

---

### 2. [Advanced Usage](advanced-usage.yml)
Comprehensive example showing all available configuration options.

**Use this if:**
- You need fine-grained control
- You want custom label prefixes
- You need specific conflict handling
- You want to cherry-pick to explicit branches without labels

**Features:**
- All input options documented
- Conflict handling with placeholder PRs
- Custom label prefixes
- Explicit target branches
- Dry-run mode for testing
- Detailed logging options
- Organization membership checks

---

### 3. [GitHub Enterprise](github-enterprise.yml)
Configuration for GitHub Enterprise Server installations.

**Use this if:**
- You're using GitHub Enterprise Server (not GitHub.com)
- You have a self-hosted GitHub instance

**Features:**
- Custom API endpoint configuration
- Enterprise authentication
- Self-hosted runner setup
- Connectivity troubleshooting guide

**Requirements:**
- GitHub Enterprise Server instance
- PAT or GitHub App with appropriate permissions
- Self-hosted runners with network access to GHE

---

### 4. [GPG Signing](gpg-signing.yml)
Enable GPG commit signing for cherry-picked commits.

**Use this if:**
- You require signed commits
- You want verified badges on commits
- Your repository enforces signature verification

**Features:**
- GPG key configuration
- Passphrase handling
- Signature verification setup
- Complete key generation guide

**Requirements:**
- GPG private key (ASCII-armored or base64)
- Optional passphrase
- Public key added to GitHub account

---

## Quick Start

1. **Choose an example** that matches your use case
2. **Copy the workflow file** to `.github/workflows/` in your repository
3. **Customize** the configuration values as needed
4. **Commit and push** the workflow file
5. **Test** by merging a PR and adding a cherry-pick label

## Common Customizations

### Change Label Prefix
```yaml
with:
  label_prefix: "backport/"  # Now use "backport/release-v2.8" instead
```

### Handle Conflicts Gracefully
```yaml
with:
  conflict_strategy: "placeholder-pr"  # Creates PR even with conflicts
```

### Test Safely First
```yaml
with:
  dry_run: true  # No actual changes made
  log_level: debug  # See detailed logs
```

### Cherry-pick to Specific Branches
```yaml
with:
  target_branches: |
    release-v2.8
    release-v2.7
```

### Require Organization Membership
```yaml
with:
  require_org_membership: true  # Only allow org members
```

## Combining Examples

You can mix and match features from different examples:

```yaml
- uses: rancher/cherry-pick-action@v1
  with:
    # From basic
    github_token: ${{ secrets.GITHUB_TOKEN }}
    
    # From advanced
    conflict_strategy: "placeholder-pr"
    log_level: "debug"
    
    # From github-enterprise
    github_base_url: https://github.example.com/api/v3
    github_upload_url: https://github.example.com/api/uploads
    
    # From gpg-signing
    git_signing_key: ${{ secrets.GPG_PRIVATE_KEY }}
    git_signing_passphrase: ${{ secrets.GPG_PASSPHRASE }}
```

## Testing Your Configuration

Before deploying to production:

1. **Enable dry-run mode:**
   ```yaml
   with:
     dry_run: true
     log_level: debug
   ```

2. **Merge a test PR** with a cherry-pick label

3. **Review the logs** in the Actions tab

4. **Verify the behavior** matches expectations

5. **Disable dry-run** and deploy:
   ```yaml
   with:
     dry_run: false
   ```

## Troubleshooting

### Workflow Not Triggering
- Verify workflow file is in `.github/workflows/`
- Check workflow file syntax (use a YAML validator)
- Ensure workflow is on the default branch
- Check if PR was actually merged (not just closed)

### Permission Errors
- Verify `github_token` has `contents: write` permission
- For protected branches, use a PAT with admin rights
- Check repository settings → Actions → General → Workflow permissions

### Cherry-Pick Failures
- Review the action logs for specific error messages
- Enable debug logging: `log_level: debug`
- Check if target branch exists
- Verify commit can be cherry-picked (no major conflicts)

### Enterprise Connection Issues
- Verify API URLs are correct and accessible
- Check firewall rules allow runner → GHE communication
- Test with dry-run first
- Verify token has correct permissions

## Support

For more help:
- [Main README](../README.md) - Full documentation
- [Troubleshooting Guide](../README.md#troubleshooting) - Common issues
- [Migration Guide](../MIGRATION.md) - Migrating from bash version
- [GitHub Issues](https://github.com/rancher/cherry-pick-action/issues) - Report bugs or ask questions
