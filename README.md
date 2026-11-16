# my_app

Flutter application with a MongoDB-backed contacts manager.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Contacts

The Contacts section supports listing, searching, creating, editing, and deleting contacts, contact photos, phone/SMS/email actions, and copying contact details.

Set up a MongoDB Atlas database and create a database user with access only to the contacts database. Allow only your development IP address in Atlas Network Access. Do not commit the connection URI or credentials.

Build the web app, then start the local server:

```powershell
flutter build web
npm install --prefix server
npm start --prefix server
```

Open `http://127.0.0.1:3000/` in Chrome. The server provides both the Flutter web files and contacts API.

The local `secrets.json` file is Git-ignored and is read only by the API. It must contain the Atlas URI under `MONGO_URI`. The API listens only on `127.0.0.1:3000` and uses the `contacts_db` database. URL-encode special characters in the username and password. Do not pass `secrets.json` to Flutter Web; database credentials must never be embedded in browser code. This unauthenticated API is for local coursework only. A production deployment requires an authenticated backend and must not expose the database directly.

## Checks

```powershell
flutter analyze
flutter test
flutter build web
```
