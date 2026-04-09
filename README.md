# SkillTrade

A native iOS/iPadOS app that connects homeowners with local tradespeople, built with Swift and SwiftUI.

## Overview

SkillTrade is a two-sided marketplace prototype. Homeowners describe a problem, get matched to a relevant tradesperson, and submit a booking. Tradespeople see incoming requests and can confirm or decline them. All data is currently hardcoded — the architecture is designed so Firebase can be swapped in with minimal changes.

## Tech Stack

- **Language**: Swift 5.0
- **UI Framework**: SwiftUI + MVVM
- **Minimum Deployment Target**: iOS 17+
- **Supported Devices**: iPhone and iPad
- **Backend**: None yet — all data lives in `MockDataService.swift`

## What's Built (v0.1 POC)

### Role Selection
On launch, the user picks which side of the marketplace they are on — no authentication required.

### Homeowner Flow
| Screen | What it does |
|---|---|
| Home | Search bar with keyword-to-category matching; lists current bookings with color-coded status badges |
| Search Results | Filtered list of providers for the resolved category (plumber, electrician, HVAC, roofer, handyman) |
| Provider Profile | Business name, bio, services offered, star rating, and customer reviews |
| Booking Form | Service picker, issue description field, date picker; submits a new pending booking |

**Keyword matching logic** (`MockDataService.resolveCategory`):
- "leak", "pipe", "water", "drain", "faucet" → Plumber
- "light", "outlet", "electric", "wire", "circuit" → Electrician
- "heat", "AC", "cool", "hvac", "furnace", "air" → HVAC
- "roof", "shingle", "gutter" → Roofer
- anything else → Handyman

### Provider Flow
| Screen | What it does |
|---|---|
| Dashboard | Two sections — Pending Requests and Upcoming Confirmed — filtered to the logged-in provider |
| Booking Detail | Full booking info with Confirm and Decline buttons that update status in memory |
| My Profile | Static view of name, business, services, rating, and stats |

### Mock Data
- 8 providers across 5 categories
- 20 reviews (2–3 per provider)
- 2 hardcoded users: Alex Johnson (homeowner) and Marco Rivera (provider)
- 3 seed bookings in varying statuses (confirmed, pending, completed)

## Project Structure

```
SkillTrade/
├── SkillTrade/
│   ├── SkillTradeApp.swift              # App entry point (@main)
│   ├── ContentView.swift                # Thin alias → RoleSelectionView
│   ├── Models.swift                     # User, Provider, Booking, Review, enums
│   ├── MockDataService.swift            # All hardcoded data + query helpers
│   ├── HomeownerViewModel.swift         # Search, booking list, add booking
│   ├── ProviderViewModel.swift          # Dashboard filtering, confirm/decline
│   ├── RoleSelectionView.swift          # Launch screen / role picker
│   ├── HomeownerRootView.swift          # NavigationStack wrapper for homeowner
│   ├── HomeownerHomeView.swift          # Search bar + My Bookings
│   ├── SearchResultsView.swift          # Provider list for a category
│   ├── ProviderProfileView.swift        # Full provider detail + Book Now
│   ├── BookingFormView.swift            # Booking submission form
│   ├── ProviderRootView.swift           # TabView wrapper for provider
│   ├── ProviderDashboardView.swift      # Pending + Confirmed booking lists
│   ├── ProviderBookingDetailView.swift  # Booking detail + action buttons
│   └── ProviderMyProfileView.swift      # Static provider profile
└── SkillTrade.xcodeproj/
```

## Prerequisites

- macOS with Xcode 16 or later
- An Apple Developer account (free tier works for Simulator)
- iOS 17+ Simulator or physical device

## Running Locally

1. **Clone the repository**

   ```bash
   git clone git@github.com:Kavinraj23/skilltrade.git
   cd skilltrade
   ```

2. **Open the project**

   ```bash
   open SkillTrade.xcodeproj
   ```

3. **Add the Swift files to the Xcode target** (first time only)

   In the Project Navigator, right-click the `SkillTrade` group → **Add Files to "SkillTrade"** → select all `.swift` files → **Add**.

4. **Select a run destination** in the Xcode toolbar (e.g. iPhone 16 Simulator).

5. **Build and run** with `Cmd + R`.

## Swapping in Firebase

All data access is isolated to `MockDataService.swift`. To migrate:

1. Replace each method body in `MockDataService` with a Firestore call.
2. Change `@Published var bookings: [Booking]` in the ViewModels to async-load from Firestore.
3. No view code needs to change.

## Future Steps

### Backend & Auth
- [ ] Firebase project setup (Firestore + Firebase Auth)
- [ ] Email/password and Sign in with Apple authentication
- [ ] Real user accounts with roles stored in Firestore
- [ ] Replace `MockDataService` methods with Firestore listeners

### Homeowner Features
- [ ] Real-time search with Firestore queries or Algolia
- [ ] In-app messaging thread per booking
- [ ] Push notifications when a provider confirms or declines
- [ ] Review and rating submission after job completion
- [ ] Booking history with filtering by status

### Provider Features
- [ ] Profile editing (bio, services, photos)
- [ ] Availability calendar
- [ ] Push notifications for new booking requests
- [ ] Earnings summary screen

### Payments
- [ ] Stripe integration for deposit or full payment at booking
- [ ] Payout flow for providers

### Discovery & Trust
- [ ] Map view showing nearby providers
- [ ] Provider verification badge (license upload)
- [ ] Category browsing (not just search)

### Polish
- [ ] App icon and launch screen
- [ ] Onboarding walkthrough for first-time users
- [ ] Accessibility audit (VoiceOver, Dynamic Type)
- [ ] Dark mode QA pass
- [ ] TestFlight beta distribution

## Contributing

1. **Branch off `main`**

   ```bash
   git checkout main && git pull
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**, keeping commits focused and descriptive.

3. **Open a pull request** against `main` with a clear description of what changed and why.

### Code Style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- Keep views composable and small — extract subviews freely.
- All ViewModels are `@MainActor ObservableObject`; keep data mutations there, not in views.
- No third-party dependencies without prior discussion.

## Build Configurations

| Configuration | Purpose |
|---|---|
| Debug | Local development — assertions and logging enabled |
| Release | Production builds — optimized, assertions stripped |

Switch via **Product > Scheme > Edit Scheme** in Xcode.
