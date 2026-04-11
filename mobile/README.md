# DEALAK Mobile App

Mobile application for DEALAK Real Estate Platform.

## Tech Stack

- React Native 0.74
- Expo 51
- Expo Router
- TypeScript
- Zustand (State Management)
- React Query (Server State)
- React Hook Form
- Zod (Validation)
- React Native Maps

## Setup

1. Install dependencies:
```bash
npm install
```

2. Start development server:
```bash
npm start
```

3. Run on iOS:
```bash
npm run ios
```

4. Run on Android:
```bash
npm run android
```

## Available Scripts

- `npm start` - Start Expo development server
- `npm run ios` - Run on iOS simulator
- `npm run android` - Run on Android emulator
- `npm run web` - Run in web browser

## Project Structure

```
mobile/
├── app/                 # Expo Router pages
│   ├── (tabs)/         # Tab navigation
│   ├── property/       # Property details
│   ├── search/         # Search page
│   ├── login/          # Login page
│   └── register/       # Registration page
├── assets/             # Images and icons
├── components/         # Reusable components
├── hooks/              # Custom hooks
├── services/           # API services
├── store/              # Zustand stores
└── types/              # TypeScript types
```

## Screens

- Home - Featured properties and categories
- Search - Advanced search with filters
- Favorites - Saved properties
- Profile - User profile and settings
- Property Details - Property information
- Login - User authentication
- Register - User registration

## Features

- 📱 Cross-platform (iOS, Android, Web)
- 🌐 RTL support for Arabic
- 🎨 Modern UI
- 🔍 Advanced search
- 🏠 Property listings
- 👤 User authentication
- ❤️ Favorites system
- 📍 Location services
- 🔔 Push notifications
