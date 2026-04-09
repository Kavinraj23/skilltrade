# SkillTrade

A native iOS/iPadOS app for trading and exchanging skills between users, built with SwiftUI.

## Overview

SkillTrade connects people who want to exchange their expertise — offer a skill you have, find a skill you want. The app is in early active development.

## Tech Stack

- **Language**: Swift 5.0
- **UI Framework**: SwiftUI
- **Minimum Deployment Target**: iOS 26.2+
- **Supported Devices**: iPhone and iPad

## Prerequisites

- macOS with Xcode 16 or later installed
- An Apple Developer account (free tier works for Simulator)
- iOS 26.2+ device or Simulator (included with Xcode)

## Running Locally

1. **Clone the repository**

   ```bash
   git clone git@github.com:Kavinraj23/skilltrade.git
   cd skilltrade
   ```

2. **Open the project in Xcode**

   ```bash
   open SkillTrade.xcodeproj
   ```

3. **Select a run destination**

   In the Xcode toolbar, choose a Simulator (e.g. iPhone 16) or a connected physical device.

4. **Build and run**

   Press `Cmd + R` or go to **Product > Run**.

   The app will build and launch in the selected Simulator or device.

## Project Structure

```
SkillTrade/
├── SkillTrade/
│   ├── SkillTradeApp.swift     # App entry point (@main)
│   ├── ContentView.swift       # Root SwiftUI view
│   └── Assets.xcassets/        # Images, icons, and color sets
└── SkillTrade.xcodeproj/       # Xcode project and workspace config
```

## Contributing

1. **Branch off `main`**

   ```bash
   git checkout main && git pull
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**, keeping commits focused and descriptive.

3. **Open a pull request** against `main` with a clear description of what changed and why.

### Code Style

- Follow standard Swift API Design Guidelines.
- Use SwiftUI's declarative patterns — keep views composable and small.
- Default actor isolation is `MainActor` (already configured in the project).
- No third-party dependencies without prior discussion.

## Build Configurations

| Configuration | Purpose |
|---|---|
| Debug | Local development — assertions and logging enabled |
| Release | Production builds — optimized, assertions stripped |

Switch configurations via **Product > Scheme > Edit Scheme** in Xcode.
