# CheckIn - Subsidized Shop Access App

CheckIn (don't know if this will be the name :) is a flutter based mobile app designed to help the Nigerian government and partners regulate access to subsidized food shops. It ensures that vulnerble citizens can only enter once a week and are limited to a fixed spending threshold.

The spending threshold and restricted access was needed to deter customers from buying in bulk and reseelling the goods.

## Features

🔐 Secure Login: Username/password-based access, not tied to emails.

🆔 NIN & Voter Card Check-In: Validate visitor identity before entry.

📅 Visit Logging: Tracks last visit and full visit history.

🚫 Access Control: Denies entry if a visitor has already checked in within 7 days.

✅ Registration System: Register unrecognized NINs with personal details.

🔄 Firestore Integration: Stores user data, visit dates, and validation info.

🔄 Future Integration: Using fingerprint functionality for faster access and recognition.

## Technology

Flutter (UI Framework)
Firebase Firestore - Cloud Database
Firebase Core
Cloud Firestore plugin

## Setup Instructions
Clone the repo:
git clone https://github.com/nkemjikaa/checkin.git
cd checkin

Install dependencies:
flutter pub get

Add Firebase Configs:
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

Run the app:
flutter run


