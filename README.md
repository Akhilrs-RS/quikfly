# QuikFly Super App ⚡

QuikFly is a multi-service "Super App" for ride-hailing (Bike Taxi, Car Taxi), delivery (food, groceries, packages), and travel getaways built with **Full-Stack Dart**, **Flutter**, and **MySQL 8.0**.

Based on the Figma mobile design system (`iPhone 16 - 5` and `Explore QuikFly`).

---

## 🏗️ Repository Architecture

```
quick/
├── packages/
│   └── quikfly_core/         # Shared Dart models, DTOs & validations
│       ├── lib/
│       │   ├── models/       # ServiceItem, BannerItem, MerchantItem, UserModel
│       │   ├── dtos/         # HomeFeedDTO, ExploreFeedDTO
│       │   └── quikfly_core.dart
├── backend/                  # Full-Stack Dart REST API (Shelf)
│   ├── bin/
│   │   └── server.dart       # API server running on port 8080
│   ├── lib/
│   │   ├── database/         # MySQL Connection Pool & queries
│   │   └── modules/catalog/  # Feed controllers (/home/feed, /explore)
│   └── pubspec.yaml
├── frontend/                 # Flutter Mobile & Multiplatform App
│   ├── lib/
│   │   ├── app/              # GoRouter, AppTheme, AppColors
│   │   ├── core/network/     # Dio ApiClient with resilient fallback
│   │   └── features/
│   │       ├── home/         # Screen 1: Home Dashboard (Hero carousel, 8-Grid, Quick Ride)
│   │       ├── explore/      # Screen 2: Explore Catalog (Category filters, Curated Getaways)
│   │       └── navigation/   # StatefulShellRoute persistent bottom navigation
│   └── pubspec.yaml
└── docker/
    ├── docker-compose.yml    # MySQL 8.0 container setup
    └── mysql/
        └── init.sql          # Database schema & Figma seed data
```

---

## 🚀 Quick Start Guide

### 1. Database (MySQL 8.0)
To run MySQL using Docker:
```bash
cd docker
docker compose up -d
```
*Note: If Docker is not running, the Dart backend automatically boots with built-in high-fidelity seed data so you can develop immediately without blockers.*

### 2. Start the Dart Backend API
```bash
cd backend
dart pub get
dart run bin/server.dart
```
The server will start at `http://localhost:8080`.
- Health Check: `http://localhost:8080/health`
- Home Feed: `http://localhost:8080/api/v1/home/feed`
- Explore Feed: `http://localhost:8080/api/v1/explore`

### 3. Start the Flutter App
```bash
cd frontend
flutter pub get
flutter run -d macos    # Or -d chrome, or target an iOS / Android simulator
```

---

## 📱 Implemented Figma Screens & Features

- **Home Screen (`iPhone 16 - 5`)**:
  - Location Selector with delivery address chip (`Indiranagar, Bengaluru`).
  - Search bar with filter/tune button.
  - Promotional Hero Banner Carousel (*"Move smarter. Live easier."*).
  - 8-Service Grid with custom color-coded badges (Bike Taxi, Car Taxi, Food, Grocery, Bus, Delivery, Rentals, Marketplace).
  - Quick Ride Widget with GPS location and destination bottom sheet.
  - "Popular near you" horizontal cards with delivery time & ratings (`Spice & Co.`, `Fresh Basket`).
  - Trust & Safety 24/7 emergency support banner.
- **Explore Screen (`Explore QuikFly`)**:
  - Filter chips (`All`, `Everyday`, `Travel`, `Shopping`).
  - 2-Column detailed services catalog with chevrons.
  - "Weekend Inspiration" full-width curated escape card (*"Breathe in the hills"*).
  - Flights & Hotels travel section.
- **Persistent Bottom Navigation**:
  - Smooth tab switching between `Home`, `Explore`, `Orders`, and `Account` with floating quick action button.
