//
//  GitReference.swift
//  MyFirstApp
//
//  Created by [Your Name] on 2025-08-29.
//  Copyright © 2025 [Your Company]. All rights reserved.
//

import Foundation

/// A comprehensive guide to Git commands and version control best practices
struct GitReference {
    
    // MARK: - Basic Commands
    static let initialize = "git init"
    static let clone = "git clone <repository-url>"
    static let status = "git status"
    
    // MARK: - Committing Changes
    static let addAll = "git add ."
    static let addFile = "git add <file>"
    static let commit = "git commit -m \"Your message\""
    
    // MARK: - Branching
    static let newBranch = "git checkout -b <branch-name>"
    static let switchBranch = "git checkout <branch-name>"
    static let listBranches = "git branch"
    
    // MARK: - Remote Operations
    static let push = "git push origin <branch-name>"
    static let pull = "git pull origin <branch-name>"
    
    // MARK: - Merging
    static let merge = "git merge <branch-name>"
    
    // MARK: - Viewing History
    static let log = "git log --oneline --graph --all"
    
    // MARK: - Undoing Changes
    static let undoAdd = "git restore --staged <file>"
    static let discardChanges = "git restore <file>"
    
    // MARK: - Stashing
    static let stash = "git stash"
    static let popStash = "git stash pop"
    
    // MARK: - Best Practices
    static let bestPractices = """
    1. Write clear, descriptive commit messages
    2. Make small, focused commits
    3. Use meaningful branch names
    4. Regularly pull from the remote repository
    5. Never force push to shared branches
    6. Use .gitignore to exclude unnecessary files
    """
}
