//
//  GitCommands.swift
//  MyFirstApp
//
//  Created by [Your Name] on 2025-08-29.
//  Copyright © 2025 [Your Company]. All rights reserved.
//

import Foundation

/// A comprehensive guide to Git commands and version control best practices
struct GitCommands {
    
    // MARK: - Basic Commands
    
    /// Initialize a new Git repository
    static let initialize = """
    // Initialize a new Git repository
    git init
    """
    
    /// Clone an existing repository
    static let clone = """
    // Clone a repository
    git clone <repository-url>
    """
    
    // MARK: - Basic Workflow
    
    /// Check repository status
    static let status = """
    // Check the status of your working directory
    git status
    """
    
    /// Stage changes
    static let add = """
    // Stage all changes
    git add .
    
    // Stage specific file
    git add <file-name>
    
    // Stage parts of a file interactively
    git add -p
    """
    
    /// Commit changes
    static let commit = """
    // Commit with a message
    git commit -m "Your descriptive commit message"
    
    // Amend the last commit
    git commit --amend
    """
    
    // MARK: - Branching
    
    /// Branch management
    static let branching = """
    // List all branches
    git branch
    
    // Create a new branch
    git branch <branch-name>
    
    // Switch to a branch
    git checkout <branch-name>
    
    // Create and switch to a new branch
    git checkout -b <new-branch-name>
    
    // Delete a branch
    git branch -d <branch-name>  // Safe delete (only if merged)
    git branch -D <branch-name>  // Force delete (even if not merged)
    """
    
    // MARK: - Remote Operations
    
    /// Remote repository management
    static let remote = """
    // Add a remote repository
    git remote add origin <repository-url>
    
    // View remote repositories
    git remote -v
    
    // Push changes to remote
    git push -u origin <branch-name>
    
    // Pull changes from remote
    git pull origin <branch-name>
    
    // Fetch changes from remote
    git fetch
    """
    
    // MARK: - Merging & Rebasing
    
    /// Merge and rebase operations
    static let mergeRebase = """
    // Merge a branch into current branch
    git merge <branch-name>
    
    // Rebase current branch onto another branch
    git rebase <branch-name>
    
    // Abort a rebase in progress
    git rebase --abort
    
    // Continue a rebase after resolving conflicts
    git rebase --continue
    """
    
    // MARK: - Stashing
    
    /// Stash changes
    static let stash = """
    // Stash changes
    git stash
    
    // List stashes
    git stash list
    
    // Apply most recent stash
    git stash apply
    
    // Apply specific stash
    git stash apply stash@{n}
    
    // Drop a stash
    git stash drop stash@{n}
    
    // Clear all stashes
    git stash clear
    """
    
    // MARK: - Viewing History
    
    /// View commit history
    static let log = """
    // View commit history
    git log
    
    // View commit history with graph
    git log --graph --oneline --all
    
    // View changes in commits
    git log -p
    
    // View who changed what and when
    git blame <file-name>
    """
    
    // MARK: - Undoing Changes
    
    /// Undo changes
    static let undo = """
    // Discard changes in working directory
    git restore <file>
    
    // Unstage a file
    git restore --staged <file>
    
    // Reset to a specific commit
    git reset --hard <commit-hash>
    
    // Revert a commit
    git revert <commit-hash>
    """
    
    // MARK: - Submodules
    
    /// Work with submodules
    static let submodules = """
    // Add a submodule
    git submodule add <repository-url>
    
    // Initialize submodules
    git submodule init
    
    // Update submodules
    git submodule update
    """
    
    // MARK: - Git Flow (Branching Strategy)
    
    /// Git Flow workflow
    static let gitFlow = """
    // Initialize Git Flow
    git flow init
    
    // Start a feature
    git flow feature start <feature-name>
    
    // Finish a feature
    git flow feature finish <feature-name>
    
    // Start a release
    git flow release start <version>
    
    // Finish a release
    git flow release finish <version>
    
    // Start a hotfix
    git flow hotfix start <version>
    
    // Finish a hotfix
    git flow hotfix finish <version>
    """
    
    // MARK: - Best Practices
    
    /// Git best practices
    static let bestPractices = """
    1. Write clear, descriptive commit messages
    2. Make small, focused commits
    3. Use meaningful branch names
    4. Regularly pull from the remote repository
    5. Never force push to shared branches
    6. Use .gitignore to exclude unnecessary files
    7. Review changes before committing
    8. Keep your working directory clean
    """
    
    // MARK: - Common Issues and Solutions
    
    /// Common Git issues and solutions
    static let commonIssues = """
    // Resolve merge conflicts
    // 1. Open the conflicted files
    // 2. Look for <<<<<<<, =======, and >>>>>>> markers
    // 3. Edit the file to resolve conflicts
    // 4. git add <resolved-file>
    // 5. git commit -m "Resolved merge conflict"
    
    // Recover a deleted branch
    git reflog
    git checkout -b <branch-name> <commit-hash>
    
    // Change the last commit message
    git commit --amend -m "New commit message"
    
    // Remove a file from Git without deleting it from disk
    git rm --cached <file>
    """
    
    // MARK: - GitHub Specific
    
    /// GitHub specific commands
    static let github = """
    // Create a pull request from command line (using GitHub CLI)
    gh pr create --title "Title" --body "Description"
    
    // View pull requests
    gh pr list
    
    // Checkout a pull request
    gh pr checkout <pr-number>
    
    // Merge a pull request
    gh pr merge <pr-number>
    """
    
    // MARK: - Advanced Commands
    
    /// Advanced Git commands
    static let advanced = """
    // Interactive rebase (last 3 commits)
    git rebase -i HEAD~3
    
    // Find which commit introduced a bug (binary search)
    git bisect start
    git bisect bad
    git bisect good <commit-hash>
    
    // Clean untracked files
    git clean -fd
    
    // Show what changed in a commit
    git show <commit-hash>
    
    // List all remote branches
    git branch -r
    
    // Prune remote-tracking branches
    git remote prune origin
    """
}

// MARK: - Git Workflow Example

struct GitWorkflowExample {
    
    /// Example workflow for a new feature
    static let featureWorkflow = """
    // Start a new feature
    git checkout main
    git pull origin main
    git checkout -b feature/new-awesome-feature
    
    // Make changes and commit
    git add .
    git commit -m "Implement new awesome feature"
    
    // Push to remote
    git push -u origin feature/new-awesome-feature
    
    // Create pull request (on GitHub/GitLab UI or using CLI)
    // After PR is reviewed and approved:
    
    // Merge into main
    git checkout main
    git merge --no-ff feature/new-awesome-feature
    git push origin main
    
    // Clean up
    git branch -d feature/new-awesome-feature
    git push origin --delete feature/new-awesome-feature
    """
    
    /// Example workflow for a hotfix
    static let hotfixWorkflow = """
    // Start a hotfix branch from main
    git checkout main
    git pull origin main
    git checkout -b hotfix/urgent-fix
    
    // Make and commit the fix
    git add .
    git commit -m "Fix critical issue"
    
    // Merge back to main and develop
    git checkout main
    git merge --no-ff hotfix/urgent-fix
    git push origin main
    
    git checkout develop
    git merge --no-ff hotfix/urgent-fix
    git push origin develop
    
    // Clean up
    git branch -d hotfix/urgent-fix
    git push origin --delete hotfix/urgent-fix
    """
}
