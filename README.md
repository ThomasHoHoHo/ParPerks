# ParPerks iOS Application
# Made by Thomas Ho
## Overview

ParPerks is a modern iOS application built to centralize perks, rewards, discounts, and exclusive offers into a single mobile platform. The app provides users with an intuitive experience for discovering, saving, and redeeming rewards while allowing businesses and organizations to engage users through personalized incentives and promotions.

The goal of ParPerks is to simplify how users interact with loyalty programs and exclusive offers by creating a seamless, mobile-first experience with real-time updates, modern UI/UX, secure authentication, and scalable backend architecture.

---

# Features

## User Features

### Authentication & User Accounts
- Email/password authentication
- Secure session management
- Persistent login
- Profile management
- Password reset functionality
- Apple Sign-In support *(optional/in progress)*

### Perks & Rewards System
- Browse available perks and offers
- Search and filter rewards
- View detailed perk information
- Save favorite perks
- Redeem perks directly in-app
- Expiration tracking for offers

### Personalized Experience
- User-specific recommendations
- Dynamic content based on preferences
- Recently viewed perks
- Trending and featured offers

### Real-Time Functionality
- Live updates from backend APIs
- Real-time perk availability
- Push notification support *(planned/in progress)*

### Mobile Experience
- Native iOS performance
- Responsive layouts
- Smooth animations and transitions
- Dark mode support
- Accessibility support

---

# Tech Stack

## Frontend (iOS)

| Technology | Purpose |
|---|---|
| Swift | Primary programming language |
| SwiftUI | Declarative UI framework |
| UIKit | Legacy/custom UI components |
| Combine | State management and reactive programming |
| MVVM Architecture | Clean separation of concerns |
| Xcode | Development environment |

---

## Backend

| Technology | Purpose |
|---|---|
| Firebase / Supabase / Node.js Backend | Authentication & data storage |
| REST APIs | Data communication |
| Cloud Functions | Server-side logic |
| PostgreSQL / Firestore | Database management |

> Update this section to match your actual backend implementation.

---

## APIs & Integrations

### Authentication APIs
- Firebase Authentication
- Apple Authentication
- OAuth integrations *(optional)*

### Database APIs
- Firestore
- PostgreSQL
- Supabase APIs

### Notification Services
- Firebase Cloud Messaging (FCM)
- Apple Push Notification Service (APNs)

### Analytics & Monitoring
- Firebase Analytics
- Crashlytics
- Sentry *(optional)*

### Networking
- URLSession
- Alamofire *(if applicable)*

---

# Architecture

ParPerks follows the **MVVM (Model-View-ViewModel)** architecture pattern.

## Why MVVM?

The MVVM pattern was chosen to:
- Improve scalability
- Separate business logic from UI
- Improve code maintainability
- Simplify testing
- Support reusable components

---

## Architecture Breakdown

### Models
Responsible for:
- Data structures
- Codable API models
- Database entities

### Views
Responsible for:
- UI rendering
- User interactions
- Layout and navigation

### ViewModels
Responsible for:
- Business logic
- API calls
- State management
- Data transformation

### Services
Responsible for:
- Networking
- Authentication
- Database access
- External integrations

---

# Project Structure

```text
ParPerks/
├── App/
├── Models/
├── Views/
├── ViewModels/
├── Services/
├── Networking/
├── Components/
├── Resources/
├── Assets/
├── Extensions/
├── Utilities/
└── SupportingFiles/
```
---

# Installation & Setup

## Prerequisites

Before running the project, make sure you have:

- macOS
- Xcode 15+
- iOS 17+
- CocoaPods or Swift Package Manager
- Firebase account *(if applicable)*

---

# API Design

ParPerks communicates with backend services using RESTful APIs.

## Example Endpoints

### Authentication

```http
POST /api/auth/login
POST /api/auth/register
POST /api/auth/logout
```

### Perks

```http
GET /api/perks
GET /api/perks/{id}
POST /api/perks/redeem
```

### User Data

```http
GET /api/users/profile
PUT /api/users/profile
```

---

# Security

Security is a major focus of ParPerks.

## Security Features
- Secure authentication
- Encrypted API communication (HTTPS)
- Secure token storage
- Input validation
- Environment-based configuration
- Protected API endpoints

---

# Performance Optimizations

- Lazy loading views
- Async networking
- Image caching
- Efficient state management
- Optimized API requests
- Background task handling

---

# Future Improvements

## Planned Features

- [ ] Push notifications
- [ ] Apple Watch support
- [ ] AI-powered recommendations
- [ ] QR code perk redemption
- [ ] Social features
- [ ] Referral system
- [ ] In-app messaging
- [ ] Offline mode support
- [ ] App Store deployment

---

# About the Developer

Developed by Thomas Ho.

Background:
- Master of Software Development student at the University of Utah
- Experience in healthcare and software engineering
- Focused on mobile development, backend systems, and scalable application architecture
