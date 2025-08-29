# 🛠 MyFirstApp Developer & Stakeholder Guide

_A comprehensive guide to understanding, maintaining, and extending the MyFirstApp project._

---

## 🏠 Overview

**MyFirstApp** is a modern iOS application built with SwiftUI, designed to help users manage their shopping lists efficiently. This guide serves as the central documentation hub for developers, designers, and stakeholders involved in the project.

### Key Technical Decisions
- **Architecture**: MVVM (Model-View-ViewModel) pattern
- **State Management**: `@EnvironmentObject`, `@State`, and `@Binding`
- **Persistence**: UserDefaults with JSON encoding
- **Minimum iOS Version**: 15.0
- **Development Environment**: Xcode 13.0+, Swift 5.5+

---

## 🚀 Latest Updates

### v1.2.0 (2025-08-29, build 2025.08.29.1106)
- Improved Deleted tab: better empty state, mutually exclusive status for deleted lists, batch delete
- Enhanced Statistics tab with granular progress and more metrics
- About section now displays detailed version/build/timestamp
- UI/UX refinements and bug fixes in Profile, Storage, and tab navigation

---

## 🧩 Project Structure

