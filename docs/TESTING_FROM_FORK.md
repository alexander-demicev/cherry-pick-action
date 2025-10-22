# Testing the Action from Your Fork

This guide explains how to test the cherry-pick action from your personal fork before submitting to the main repository.

---

## 📋 Prerequisites

- Forked repository: `your-username/cherry-pick-action`
- Test repository where you'll use the action
- GitHub Personal Access Token (PAT) with appropriate permissions

---

## 🚀 Step 1: Push Your Code to Fork

```bash
# Make sure you're in the cherry-pick-action directory
cd /Users/ademicev/Documents/rancher/cherry-pick-action

# Check current remote
git remote -v

# Add your fork as origin (if not already set)
git remote add origin https://github.com/YOUR_USERNAME/cherry-pick-action.git
# or if origin exists:
git remote set-url origin https://github.com/YOUR_USERNAME/cherry-pick-action.git

# Push to your fork
git push origin main

# Create and push a version tag for testing
git tag v0.1.0-test
git push origin v0.1.0-test

# Also push a major version tag (optional but recommended)
git tag v0.1
git push origin v0.1
```

---

## 🧪 Step 2: Create a Test Repository

You'll need a test repository to try the cherry-pick action:

1. **Create a new test repo** (or use existing one):
   - Name: `cherry-pick-test` (or any name)
   - Add some commits on `main` branch
   - Create a release branch: `release-v1.0`

2. **Set up branch protection** (optional but recommended):
   - Go to Settings → Branches
   - Add rule for `release-v1.0`
   - Enable "Require pull request before merging"

---

## 📝 Step 3: Create Test Workflow in Test Repository

In your test repository, create `.github/workflows/cherry-pick.yml`:

```yaml
name: Cherry-Pick Automation

on:
  pull_request_target:
    types: [closed, labeled]

permissions:
  contents: write
  pull-requests: write

jobs:
  cherry-pick:
    name: Cherry-pick merged PR
    runs-on: ubuntu-latest
    if: github.event.pull_request.merged == true
    
    steps:
      - name: Cherry-pick
        uses: YOUR_USERNAME/cherry-pick-action@v0.1.0-test
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          # Optional: enable debug logging for testing
          log_level: debug
          # Optional: test dry-run first
          # dry_run: true
```

**Important:** Replace `YOUR_USERNAME` with your actual GitHub username!

### Alternative: Use SHA for Testing Specific Commits

If you want to test a specific commit without tags:

```yaml
uses: YOUR_USERNAME/cherry-pick-action@COMMIT_SHA
```

---

## 🧪 Step 4: Test Scenarios

### Test 1: Basic Cherry-Pick

1. **Create a test PR** in your test repo:
   ```bash
   # In test repository
   git checkout -b test-feature
   echo "Test feature" > feature.txt
   git add feature.txt
   git commit -m "Add test feature"
   git push origin test-feature
   ```

2. **Open PR** and add label: `cherry-pick/release-v1.0`

3. **Merge the PR**

4. **Watch the action run**:
   - Go to Actions tab
   - You should see "Cherry-Pick Automation" workflow running
   - Check logs for any errors

5. **Verify result**:
   - A new PR should be created targeting `release-v1.0`
   - PR should contain the cherry-picked commit
   - Source PR should have `cherry-pick/done/release-v1.0` label

### Test 2: Multiple Targets

1. Create another release branch: `release-v0.9`
2. Create PR with labels:
   - `cherry-pick/release-v1.0`
   - `cherry-pick/release-v0.9`
3. Merge PR
4. Verify two cherry-pick PRs are created

### Test 3: Conflict Handling

1. Create conflicting changes on `release-v1.0`
2. Create PR with `cherry-pick/release-v1.0` label
3. Merge PR
4. With default settings: Action should fail with clear error
5. Try with `conflict_strategy: placeholder-pr`:
   ```yaml
   with:
     github_token: ${{ secrets.GITHUB_TOKEN }}
     conflict_strategy: placeholder-pr
   ```
6. Should create PR with conflict notice

### Test 4: Dry Run Mode

Test without making actual changes:

```yaml
uses: YOUR_USERNAME/cherry-pick-action@v0.1.0-test
with:
  github_token: ${{ secrets.GITHUB_TOKEN }}
  dry_run: true
  log_level: debug
```

Should show what would happen without creating PRs.

### Test 5: GitHub Enterprise (if applicable)

```yaml
uses: YOUR_USERNAME/cherry-pick-action@v0.1.0-test
with:
  github_token: ${{ secrets.GHE_TOKEN }}
  github_base_url: https://github.example.com/api/v3
  github_upload_url: https://github.example.com/api/uploads
```

---

## 🔍 Step 5: Debugging

### Enable Detailed Logging

```yaml
with:
  github_token: ${{ secrets.GITHUB_TOKEN }}
  log_level: debug
  log_format: json  # structured logs for parsing
```

### Check Action Logs

1. Go to Actions tab in test repository
2. Click on failed/running workflow
3. Expand "Cherry-pick" step
4. Review detailed logs

### Common Issues and Solutions

#### Issue: "Action not found"
```
Error: Unable to resolve action `YOUR_USERNAME/cherry-pick-action@v0.1.0-test`
```
**Solution:** 
- Verify tag exists: `git tag -l`
- Verify tag is pushed: `git ls-remote --tags origin`
- Check repository is public or you have access

#### Issue: "Permission denied"
```
Error: Resource not accessible by integration
```
**Solution:**
- Add permissions to workflow:
  ```yaml
  permissions:
    contents: write
    pull-requests: write
  ```
- Or use PAT instead of `GITHUB_TOKEN`

#### Issue: "Docker image not found"
```
Error: Unable to pull image
```
**Solution:**
- Wait a few minutes for GitHub to build the image
- Check Dockerfile syntax is correct
- Verify action.yml has correct `runs.image` setting

#### Issue: Action runs but no PR created
**Check:**
- Was PR actually merged? (not just closed)
- Does target branch exist?
- Are there any errors in the logs?
- Try with `log_level: debug`

---

## 🔐 Step 6: Test with Personal Access Token (Optional)

For testing protected branches or advanced features:

1. **Create a PAT**:
   - Go to Settings → Developer settings → Personal access tokens
   - Generate new token (classic)
   - Scopes: `repo` (full control)

2. **Add to test repository secrets**:
   - Test repo → Settings → Secrets → Actions
   - New repository secret: `CHERRY_PICK_TOKEN`
   - Paste your PAT

3. **Update workflow**:
   ```yaml
   uses: YOUR_USERNAME/cherry-pick-action@v0.1.0-test
   with:
     github_token: ${{ secrets.CHERRY_PICK_TOKEN }}
   ```

---

## 📊 Step 7: Verify Test Results

Create a checklist for each test:

- [ ] Action starts successfully
- [ ] Debug logs show expected behavior
- [ ] Cherry-pick PRs created with correct content
- [ ] Done labels added to source PR
- [ ] No errors in logs
- [ ] Idempotency works (re-adding label doesn't create duplicate)
- [ ] Fork detection works (rejects PRs from forks)
- [ ] Conflict handling works as expected

---

## 🎯 Step 8: Iterate and Fix

If you find issues:

1. **Fix the code** in your fork
2. **Commit changes**:
   ```bash
   git add .
   git commit -m "Fix: description of fix"
   git push origin main
   ```

3. **Update test tag**:
   ```bash
   # Delete old tag
   git tag -d v0.1.0-test
   git push origin :refs/tags/v0.1.0-test
   
   # Create new tag
   git tag v0.1.0-test
   git push origin v0.1.0-test
   ```

4. **Re-run tests** in your test repository

---

## 🚀 Step 9: Test Reusable Workflow (Optional)

You can also test the reusable workflow pattern:

**In test repository** `.github/workflows/cherry-pick.yml`:

```yaml
name: Cherry-Pick Automation

on:
  pull_request_target:
    types: [closed, labeled]

jobs:
  cherry-pick:
    uses: YOUR_USERNAME/cherry-pick-action/.github/workflows/cherry-pick.yml@v0.1.0-test
    secrets:
      token: ${{ secrets.GITHUB_TOKEN }}
    with:
      log_level: debug
```

---

## ✅ Final Verification Checklist

Before submitting to main repository:

- [ ] All test scenarios pass
- [ ] No errors in production-like setup
- [ ] Documentation is accurate
- [ ] Examples work as documented
- [ ] Performance is acceptable
- [ ] Security concerns addressed
- [ ] Clean git history (squashed if needed)

---

## 📤 Step 10: Ready to Submit

Once testing is complete and successful:

1. **Clean up test tags** (optional):
   ```bash
   git tag -d v0.1.0-test v0.1
   git push origin :refs/tags/v0.1.0-test
   git push origin :refs/tags/v0.1
   ```

2. **Create PR to upstream**:
   - Fork of `rancher/cherry-pick-action` → main repo
   - Include test results in PR description
   - Reference any issues fixed

3. **Or tag for initial release**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   git tag v1
   git push origin v1
   ```

---

## 🆘 Need Help?

- **Action logs**: Check GitHub Actions tab in test repository
- **Build issues**: Check Dockerfile and action.yml syntax
- **Permissions**: Review permissions in workflow and token scopes
- **Conflicts**: Test with `conflict_strategy: placeholder-pr`

**Tip:** Start with `dry_run: true` to see what would happen without making changes!
