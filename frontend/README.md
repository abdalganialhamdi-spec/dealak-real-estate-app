# DEALAK Frontend Web

Frontend web application for DEALAK Real Estate Platform.

## Tech Stack

- Next.js 14
- React 18
- TypeScript
- Tailwind CSS
- Zustand (State Management)
- React Query (Server State)
- React Hook Form
- Zod (Validation)
- Leaflet (Maps)

## Setup

1. Install dependencies:
```bash
npm install
```

2. Copy environment variables:
```bash
cp .env.example .env
```

3. Start development server:
```bash
npm run dev
```

4. Open http://localhost:3000

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm run lint` - Lint code
- `npm run type-check` - Type check

## Project Structure

```
frontend/
├── src/
│   ├── app/              # Next.js App Router pages
│   ├── components/       # Reusable components
│   ├── hooks/            # Custom hooks
│   ├── lib/              # Utilities and API client
│   ├── store/            # Zustand stores
│   └── types/            # TypeScript types
├── public/               # Static assets
└── package.json
```

## Pages

- `/` - Home page
- `/login` - Login page
- `/register` - Registration page
- `/properties` - Properties listing
- `/properties/[id]` - Property details
- `/search` - Advanced search

## Features

- 🌐 RTL support for Arabic
- 🎨 Modern UI with Tailwind CSS
- 📱 Responsive design
- 🔍 Advanced search with filters
- 🏠 Property listings with details
- 👤 User authentication
- ❤️ Favorites system
- 📊 Statistics dashboard
