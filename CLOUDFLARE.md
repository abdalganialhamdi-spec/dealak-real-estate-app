# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  DEALAK Real Estate Platform — Cloudflare Deployment Guide              ║
# ║  Version:  1.0.0                                                       ║
# ║  Date:     11 April 2026                                               ║
# ╚══════════════════════════════════════════════════════════════════════════╝

## 📋 Overview

This guide explains how to deploy the DEALAK real estate platform to Cloudflare Workers and Pages.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Cloudflare Workers                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Hono Framework (API)                                      │  │
│  │  - Auth Routes                                             │  │
│  │  - Property Routes                                         │  │
│  │  - User Routes                                             │  │
│  │  - Favorite Routes                                         │  │
│  │  - Message Routes                                          │  │
│  │  - Deal Routes                                             │  │
│  │  - Review Routes                                           │  │
│  │  - Notification Routes                                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Cloudflare Services                                      │  │
│  │  - D1 Database (SQLite)                                   │  │
│  │  - KV Storage (Caching)                                   │  │
│  │  - R2 Storage (Images)                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Cloudflare Pages                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Next.js 14 Frontend                                      │  │
│  │  - Home Page                                               │  │
│  │  - Property Listing                                        │  │
│  │  - Property Details                                        │  │
│  │  - User Profile                                           │  │
│  │  - Favorites                                               │  │
│  │  - Messages                                                │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- Wrangler CLI
- Cloudflare account

### Installation

```bash
# Install Wrangler
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Install dependencies
cd backend
npm install
```

### Configuration

Update `wrangler.toml` with your Cloudflare IDs:

```toml
[[d1_databases]]
binding = "DB"
database_name = "dealak-db"
database_id = "YOUR_D1_DATABASE_ID"

[[kv_namespaces]]
binding = "CACHE"
id = "YOUR_KV_NAMESPACE_ID"

[[r2_buckets]]
binding = "STORAGE"
bucket_name = "dealak-storage"
```

### Create Cloudflare Resources

```bash
# Create D1 Database
wrangler d1 create dealak-db

# Create KV Namespace
wrangler kv:namespace create "CACHE"

# Create R2 Bucket
wrangler r2 bucket create dealak-storage
```

### Database Migration

```bash
# Run schema migration
npm run db:migrate

# Seed database
npm run db:seed
```

### Local Development

```bash
# Start local development server
npm run dev
```

The API will be available at `http://localhost:8787`

### Deployment

```bash
# Deploy to Cloudflare Workers
npm run deploy
```

## 📁 Project Structure

```
dealak-real-estate-app/
├── backend/
│   ├── worker.ts              # Main Cloudflare Worker
│   ├── routes/                # API Routes
│   │   ├── auth.routes.ts
│   │   ├── property.routes.ts
│   │   ├── user.routes.ts
│   │   ├── favorite.routes.ts
│   │   ├── message.routes.ts
│   │   ├── deal.routes.ts
│   │   ├── review.routes.ts
│   │   └── notification.routes.ts
│   ├── package-worker.json   # Worker dependencies
│   └── tsconfig-worker.json   # Worker TypeScript config
├── database/
│   ├── schema.sql             # D1 Database Schema
│   └── seed.sql               # Seed Data
├── frontend/                  # Next.js Frontend
├── mobile/                    # React Native Mobile App
└── wrangler.toml              # Cloudflare Configuration
```

## 🔌 API Endpoints

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

## 🗄️ Database Schema

The D1 database contains 19 tables:

1. **users** - User accounts
2. **user_devices** - User devices for push notifications
3. **refresh_tokens** - JWT refresh tokens
4. **properties** - Real estate properties
5. **property_features** - Property features
6. **property_images** - Property images
7. **favorites** - User favorites
8. **saved_searches** - Saved search queries
9. **requests** - Property requests
10. **deals** - Property deals
11. **payments** - Deal payments
12. **discounts** - Property discounts
13. **conversations** - User conversations
14. **messages** - Conversation messages
15. **notifications** - User notifications
16. **reviews** - Property reviews
17. **property_views** - Property view tracking
18. **audit_logs** - Audit logs
19. **system_settings** - System settings

## 🔒 Security

- JWT authentication
- Password hashing with bcrypt
- CORS enabled for specific domains
- Rate limiting (to be implemented)
- Input validation with Zod

## 📊 Monitoring

Cloudflare provides built-in monitoring:

- **Analytics** - Request metrics, error rates
- **Logs** - Worker logs
- **Real-time** - Real-time request monitoring

## 🌐 Custom Domain

To use a custom domain:

```bash
# Add custom domain to Worker
wrangler domains add api.dealak.com

# Add custom domain to Pages
wrangler pages domain create dealak.com
```

## 📝 Environment Variables

Set these in `wrangler.toml`:

```toml
[vars]
ENVIRONMENT = "production"
APP_NAME = "DEALAK"
APP_VERSION = "1.0.0"
CURRENCY = "SYP"
JWT_SECRET = "your-jwt-secret-key-change-in-production"
```

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage
```

## 📚 Additional Resources

- [Cloudflare Workers Documentation](https://developers.cloudflare.com/workers/)
- [Hono Documentation](https://hono.dev/)
- [D1 Documentation](https://developers.cloudflare.com/d1/)
- [Pages Documentation](https://developers.cloudflare.com/pages/)

## 🤝 Support

For issues or questions, contact:
- Email: support@dealak.com
- GitHub: https://github.com/abdalganialhamdi-spec/dealak-real-estate-app
