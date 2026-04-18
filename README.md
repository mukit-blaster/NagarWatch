# NagarWatch

NagarWatch is a full-stack civic engagement platform for Bangladesh.
It helps citizens report issues, submit project evidence, and track updates while helping authorities monitor, review, and respond.

This repository contains:
- A Flutter mobile/web client (`NagarWatch/`)
- A Node.js + Express + Firestore backend (`backend/`)

## Table of Contents
- [Project Highlights](#project-highlights)
- [Core Functionality](#core-functionality)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Run Commands](#run-commands)
- [API Overview](#api-overview)
- [Data Model Summary](#data-model-summary)
- [Real-Time, Notification, and Geofencing](#real-time-notification-and-geofencing)
- [Troubleshooting](#troubleshooting)
- [Security Notes](#security-notes)
- [Contribution Guide](#contribution-guide)

## Project Highlights
- Citizen and authority authentication (email/phone login, authority approval flow)
- Ward-based workflows and geofence-based area selection
- Development project listing, creation, update, and nearby discovery
- Issue reporting and status tracking
- Evidence submission and review workflow
- Real-time updates using Firestore streams
- Push notifications via Firebase Cloud Messaging (FCM)
- Local notifications + geofencing proximity alerts
- Offline-friendly local storage for selected user/session data

## Core Functionality

### 1) Authentication and Access
- Citizen registration and login
- Authority login with ward code
- Admin approval pipeline for authority requests
- Role-based experience (citizen, authority, admin)
- Ward selection and persisted ward context

### 2) Project Management
- Create and update projects
- List all projects or filter by ward
- Fetch nearby projects by latitude/longitude + radius
- View project details and progress-related updates

### 3) Issues and Complaints
- Citizens can report issues
- Authorities can monitor issue lists
- Status filtering and status updates
- Ward-aware issue views

### 4) Evidence Workflow
- Submit evidence records linked to projects
- Retrieve and filter evidence
- Evidence status transitions (review/approve/reject patterns)
- Rejection reason support

### 5) Real-Time + Geospatial Experience
- Stream-based live issue updates in UI
- Geofencing checks around issue locations
- Local notification cooldown behavior to avoid spam
- FCM topic and token support for push delivery

## Tech Stack

### Client (`NagarWatch/`)
- Flutter (Dart, Material)
- Provider (state management)
- Firebase Core, Cloud Firestore, Firebase Messaging
- HTTP client (`http`)
- Geolocator + Geocoding
- Flutter Local Notifications
- Connectivity Plus
- Shared Preferences + SQLite
- Image Picker + Cached Network Image

### Backend (`backend/`)
- Node.js + Express
- Firebase Admin SDK (Firestore)
- JSON Web Token (JWT)
- bcryptjs (password hashing)
- CORS, dotenv, multer

## Architecture

### High-level flow
1. Flutter client performs auth and feature actions through REST APIs.
2. Node/Express backend validates input and writes/reads Firestore documents.
3. Firestore provides data persistence and stream updates.
4. FCM and local notification services surface updates and geofence alerts.

### API base path
- All backend routes are mounted under `/api`.
- Health endpoint: `GET /api/health`

## Repository Structure

```text
nagarwatchfixing/
|-- backend/
|   |-- config/
|   |   |-- firebase.js
|   |-- models/
|   |   |-- User.js
|   |   |-- Project.js
|   |   |-- Issue.js
|   |   |-- Evidence.js
|   |-- routes/
|   |   |-- auth.js
|   |   |-- projects.js
|   |   |-- issues.js
|   |   |-- evidence.js
|   |-- server.js
|   |-- package.json
|   |-- .env.example
|
|-- NagarWatch/
|   |-- lib/
|   |   |-- main.dart
|   |   |-- app.dart
|   |   |-- core/
|   |   |   |-- constants/
|   |   |   |-- models/
|   |   |   |-- services/
|   |   |   |-- theme/
|   |   |   |-- widgets/
|   |   |-- routes/
|   |   |   |-- app_router.dart
|   |   |-- features/
|   |   |   |-- authentication/
|   |   |   |-- project_management/
|   |   |   |-- evidence_issue_reporting/
|   |   |   |-- authority_response_sync/
|   |   |   |-- geofencing_notifications/
|   |   |-- examples/
|   |-- android/
|   |-- ios/
|   |-- web/
|   |-- test/
|   |-- pubspec.yaml
|
|-- FIRESTORE_INTEGRATION_GUIDE.md
|-- FIRESTORE_QUICK_REFERENCE.md
|-- README.md
```

## Getting Started

## Prerequisites
- Flutter SDK (compatible with project constraints in `pubspec.yaml`)
- Dart SDK (bundled with Flutter)
- Node.js 18+ recommended
- npm
- Firebase project with Firestore enabled
- Android Studio / Xcode / Chrome (depending on target)

## 1) Backend Setup

```bash
cd backend
npm install
```

Create `.env` in `backend/` (copy from `.env.example` and replace values):

```env
PORT=3000
JWT_SECRET=change_me
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_CLIENT_EMAIL=your_service_account_email
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
# Optional:
# SUPER_ADMIN_EMAIL=admin@example.com
# SUPER_ADMIN_PASSWORD=change_me
```

Run backend:

```bash
npm run dev
# or
npm start
```

Server starts on `http://localhost:3000` by default.

## 2) Flutter App Setup

```bash
cd NagarWatch
flutter pub get
```

Run on emulator:

```bash
flutter run
```

Run on physical Android device (important):

```bash
flutter run --dart-define=API_BASE_URL=http://<YOUR_PC_LAN_IP>:3000/api
```

Build APK for physical device:

```bash
flutter build apk --dart-define=API_BASE_URL=http://<YOUR_PC_LAN_IP>:3000/api
```

Notes:
- `10.0.2.2` works for Android emulator only.
- Physical devices must use your machine LAN IP.
- Ensure phone and backend machine are on the same network.

## Environment Variables

### Backend (`backend/.env`)
- `PORT`: API port (default 3000)
- `JWT_SECRET`: JWT signing secret
- `FIREBASE_PROJECT_ID`: Firebase project id
- `FIREBASE_CLIENT_EMAIL`: Service account client email
- `FIREBASE_PRIVATE_KEY`: Service account private key
- `SUPER_ADMIN_EMAIL` (optional): bootstrap super admin login email
- `SUPER_ADMIN_PASSWORD` (optional): bootstrap super admin login password

### Flutter (`--dart-define`)
- `API_BASE_URL` (optional but recommended for device builds)
  - Example: `http://192.168.1.50:3000/api`

## Run Commands

### Backend
```bash
cd backend
npm run dev      # nodemon
npm start        # node server.js
```

### Flutter
```bash
cd NagarWatch
flutter pub get
flutter run
flutter test
flutter build apk --dart-define=API_BASE_URL=http://<LAN_IP>:3000/api
```

## API Overview

Base URL: `/api`

### Auth (`/api/auth`)
- `POST /register`
- `POST /login`
- `POST /authority-login`
- `GET /approval-requests`
- `PATCH /approval-requests/:requestId/approve`
- `PATCH /approval-requests/:requestId/reject`
- `PATCH /ward`

### Projects (`/api/projects`)
- `GET /`
- `GET /nearby?lat=<>&lng=<>&radius=<>`
- `GET /:id`
- `POST /`
- `PATCH /:id`

### Issues (`/api/issues`)
- `GET /`
- `GET /:id`
- `POST /`
- `PATCH /:id/status`

### Evidence (`/api/evidence`)
- `GET /`
- `POST /`
- `PATCH /:id/status`

### Health
- `GET /api/health`

## Data Model Summary

Firestore collections used by backend routes:
- `users`
- `projects`
- `issues`
- `evidence`
- `authority_approvals`

Common timestamps:
- `createdAt`
- `updatedAt`

## Real-Time, Notification, and Geofencing

The project includes expanded guidance in:
- `NagarWatch/IMPLEMENTATION_SUMMARY.md`
- `NagarWatch/REAL_TIME_INTEGRATION_GUIDE.md`
- `NagarWatch/SETUP_CHECKLIST.md`

Capabilities include:
- FCM token registration and topic support
- Foreground/background message handling
- StreamBuilder-based issue live updates
- Geofencing checks and proximity notifications

## Troubleshooting

### Login keeps loading on Android phone
- Ensure backend is reachable from phone using LAN IP.
- Build/run with `--dart-define=API_BASE_URL=http://<LAN_IP>:3000/api`.
- Confirm backend is running and `GET /api/health` responds.
- Check phone internet/Wi-Fi and firewall rules.

### Timeout or no internet error
- App now detects connectivity and request timeout in API service.
- Verify the network, base URL, and backend availability.

### Firebase initialization errors
- Validate all Firebase env vars in backend `.env`.
- Ensure private key formatting preserves newlines (`\n`).

## Security Notes
- Do not commit real secrets to source control.
- Rotate any exposed keys/secrets immediately.
- Use strong `JWT_SECRET` in production.
- Restrict Firestore security rules and service account scope.
- Prefer HTTPS in production environments.

## Contribution Guide

1. Create a feature branch.
2. Keep changes scoped and documented.
3. Test backend endpoints and affected Flutter flows.
4. Open a PR with clear screenshots/logs for UI or behavior changes.

## License

Add your project license here (for example, MIT).
