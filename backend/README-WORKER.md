# DEALAK Backend - Cloudflare Worker

Cloudflare Worker implementation of the DEALAK real estate platform backend.

## Features

- ✅ RESTful API with Hono framework
- ✅ D1 Database (SQLite)
- ✅ KV Storage for caching
- ✅ R2 Storage for images
- ✅ JWT Authentication
- ✅ TypeScript support
- ✅ CORS enabled

## Quick Start

```bash
# Install dependencies
npm install

# Start local development
npm run dev

# Deploy to Cloudflare
npm run deploy
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user

### Properties
- `GET /api/properties` - Get all properties
- `GET /api/properties/:id` - Get property by ID
- `POST /api/properties` - Create property
- `PUT /api/properties/:id` - Update property
- `DELETE /api/properties/:id` - Delete property

### Users
- `GET /api/users/:id` - Get user by ID

### Favorites
- `GET /api/favorites/:userId` - Get user favorites
- `POST /api/favorites` - Add favorite
- `DELETE /api/favorites/:id` - Remove favorite

### Messages
- `GET /api/messages/conversations/:userId` - Get user conversations
- `GET /api/messages/:conversationId` - Get conversation messages
- `POST /api/messages` - Send message

### Deals
- `GET /api/deals` - Get all deals
- `GET /api/deals/:id` - Get deal by ID
- `POST /api/deals` - Create deal

### Reviews
- `GET /api/reviews/property/:propertyId` - Get property reviews
- `POST /api/reviews` - Create review

### Notifications
- `GET /api/notifications/:userId` - Get user notifications
- `PUT /api/notifications/:id/read` - Mark notification as read

## Database

### Schema

See `../database/schema.sql` for the complete D1 database schema.

### Migration

```bash
# Run schema migration
npm run db:migrate

# Seed database
npm run db:seed
```

## Environment Variables

Set these in `wrangler.toml`:

```toml
[vars]
ENVIRONMENT = "production"
APP_NAME = "DEALAK"
APP_VERSION = "1.0.0"
CURRENCY = "SYP"
JWT_SECRET = "your-jwt-secret-key-change-in-production"
```

## Development

### Local Development

```bash
# Start local development server
npm run dev
```

The API will be available at `http://localhost:8787`

### Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage
```

### Linting

```bash
# Run linter
npm run lint

# Fix linting issues
npm run lint:fix
```

## Deployment

### Deploy to Cloudflare Workers

```bash
# Deploy to production
npm run deploy
```

### Custom Domain

```bash
# Add custom domain
wrangler domains add api.dealak.com
```

## Project Structure

```
backend/
├── worker.ts              # Main Cloudflare Worker
├── routes/                # API Routes
│   ├── auth.routes.ts
│   ├── property.routes.ts
│   ├── user.routes.ts
│   ├── favorite.routes.ts
│   ├── message.routes.ts
│   ├── deal.routes.ts
│   ├── review.routes.ts
│   └── notification.routes.ts
├── package-worker.json   # Worker dependencies
├── tsconfig-worker.json   # Worker TypeScript config
└── README-WORKER.md       # This file
```

## License

MIT
