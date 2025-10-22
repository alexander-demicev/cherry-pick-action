#!/bin/bash
set -e

# Quick Start Script for Testing Cherry-Pick Action from Fork
# This script helps you push your code to your fork and create test tags

echo "🚀 Cherry-Pick Action - Fork Testing Setup"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "action.yml" ]; then
    echo "❌ Error: action.yml not found. Please run this from the cherry-pick-action directory."
    exit 1
fi

# Get GitHub username
echo "📝 Please enter your GitHub username:"
read -r GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ Error: GitHub username is required"
    exit 1
fi

echo ""
echo "Setting up remote for: $GITHUB_USERNAME/cherry-pick-action"
echo ""

# Check if origin exists
if git remote get-url origin > /dev/null 2>&1; then
    echo "📍 Existing origin found:"
    git remote get-url origin
    echo ""
    echo "Do you want to update it? (y/n)"
    read -r UPDATE_REMOTE
    if [ "$UPDATE_REMOTE" = "y" ]; then
        git remote set-url origin "https://github.com/$GITHUB_USERNAME/cherry-pick-action.git"
        echo "✅ Updated origin remote"
    fi
else
    git remote add origin "https://github.com/$GITHUB_USERNAME/cherry-pick-action.git"
    echo "✅ Added origin remote"
fi

echo ""
echo "📦 Current remotes:"
git remote -v
echo ""

# Stage new files
echo "📁 Staging new documentation files..."
git add docs/
git add LAUNCH_CHECKLIST.md

echo ""
echo "📊 Current status:"
git status --short
echo ""

# Commit
echo "💾 Do you want to commit these changes? (y/n)"
read -r DO_COMMIT
if [ "$DO_COMMIT" = "y" ]; then
    echo "Enter commit message (or press enter for default):"
    read -r COMMIT_MSG
    if [ -z "$COMMIT_MSG" ]; then
        COMMIT_MSG="docs: Add security audit and testing documentation"
    fi
    git commit -m "$COMMIT_MSG"
    echo "✅ Changes committed"
else
    echo "⏭️  Skipping commit"
fi

echo ""
echo "🏷️  Creating test tag v0.1.0-test..."
git tag -f v0.1.0-test
echo "✅ Tag created"

echo ""
echo "📤 Ready to push! Commands to run:"
echo ""
echo "   git push origin main"
echo "   git push origin v0.1.0-test"
echo ""
echo "Do you want to push now? (y/n)"
read -r DO_PUSH

if [ "$DO_PUSH" = "y" ]; then
    echo ""
    echo "🚀 Pushing to origin..."
    git push origin main
    git push origin v0.1.0-test
    echo ""
    echo "✅ Code pushed successfully!"
    echo ""
    echo "📋 Next steps:"
    echo ""
    echo "1. Create a test repository (or use existing one)"
    echo "2. Add a workflow file: .github/workflows/cherry-pick.yml"
    echo "3. Use this action reference:"
    echo ""
    echo "   uses: $GITHUB_USERNAME/cherry-pick-action@v0.1.0-test"
    echo ""
    echo "4. See docs/TESTING_FROM_FORK.md for detailed instructions"
else
    echo ""
    echo "⏭️  Push skipped. Run these commands when ready:"
    echo ""
    echo "   git push origin main"
    echo "   git push origin v0.1.0-test"
fi

echo ""
echo "📖 Full testing guide: docs/TESTING_FROM_FORK.md"
echo ""
echo "✨ Setup complete!"
