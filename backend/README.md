# DEALAK Backend API

Backend API for DEALAK Real Estate Platform.

## Tech Stack

- Node.js 20 LTS
- TypeScript 5.x
- Express.js 4.x
- PostgreSQL 16+ with PostGIS
- Prisma ORM
- Redis
- Socket.io
- JWT Authentication
- Zod Validation
- Winston Logging

## Setup

1. Install dependencies:
```bash
npm install
```

2. Copy environment variables:
```bash
cp .env.example .env
```

3. Start PostgreSQL and Redis:
```bash
docker-compose up -d
```

4. Generate Prisma client:
```bash
npm run prisma:generate
```

5. Run migrations:
```bash
npm run prisma:migrate
```

6. Seed database:
```bash
npm run prisma:seed
```

7. Start development server:
```bash
npm run dev
```

## API Documentation

Swagger UI available at: http://localhost:3000/api-docs

## Project Structure

```
backend/
├── src/
│   ├── config/           # Configuration
│   ├── modules/          # Feature modules
│   ├── middleware/       # Express middleware
│   ├── shared/           # Shared utilities
│   ├── jobs/             # Background jobs
│   ├── websocket/        # Socket.io setup
│   └── app.ts            # Entry point
├── prisma/
│   ├── schema.prisma     # Database schema
│   ├── migrations/       # Migration files
│   └── seed.ts           # Seed data
└── package.json
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm run test` - Run tests
- `npm run lint` - Lint code
- `npm run prisma:generate` - Generate Prisma client
- `npm run prisma:migrate` - Run migrations
- `npm run prisma:seed` - Seed database

## Default Users

After seeding, you can login with:

- **Admin:** admin@dealak.com / admin123
- **Buyer:** buyer@example.com / password123
- **Seller:** seller@example.com / password123
- **Agent:** agent@example.com / password123
