# ApnaExpert 🛠️

**ApnaExpert** is an on-demand hyper-local home service & workforce marketplace application built with Flutter and Firebase. It seamlessly connects customers with skilled local technicians across a multi-role architecture (Customer, Service Provider, and Admin).

---

## 🌟 Key Features

### 👤 1. Customer Experience
- **Smart Location & Address Sync:** Live GPS location detection with manual address selector, synced directly with Cloud Firestore.
- **Service Categories:** Interactive catalog of home services (Plumbing, Electrical, House Cleaning, AC Repair, Appliance Servicing, etc.) with upfront base pricing.
- **Worker Discovery & Booking:** Browse nearby certified technicians, view reviews and ratings, select preferred time slots, and choose instant or scheduled bookings.
- **Live Booking Tracker:** Real-time booking status tracker with technician coordination, calling, and order history.

### 👷 2. Service Provider (Worker) Console
- **Job Request Management:** Real-time incoming service requests with instant accept/reject functionality.
- **Financial & Earnings Dashboard:** Real-time stats on completed jobs, total earnings, pending payouts, and detailed wallet ledger.
- **Payout Withdrawals:** Complete in-app withdrawal flow supporting UPI (Google Pay, PhonePe, Paytm, BHIM) and direct bank transfers.

### 🛡️ 3. Admin Control Console
- **Live Bookings Monitor:** System-wide booking supervision with dynamic status filtering and revenue volume calculation.
- **User Management:** Unified oversight of Customers, Service Providers, and Admins.
- **Category & Pricing Control:** Dynamic category creation, editing, rate configuration, and active/disabled toggle.
- **Review Moderation:** Community review moderation and verification.

---

## 🚀 Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Channel stable, Multiplatform)
- **Language:** [Dart](https://dart.dev/)
- **Backend & Database:** [Firebase](https://firebase.google.com/)
  - Firebase Authentication (Secure phone/email auth & RBAC)
  - Cloud Firestore (Real-time database for users, bookings, addresses, reviews)
  - Firebase Storage
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Design System:** Material 3, AMOLED pitch black dark mode, responsive cards, Google Fonts (Plus Jakarta Sans).

---

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
- Android Studio / VS Code with Flutter extension
- Firebase project configured with `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/vishal02verma/ApnaExpert-app.git
   cd ApnaExpert-app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

---

## 📄 License
This project is licensed under the MIT License.

