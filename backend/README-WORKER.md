# DEALAK Backend - Cloudflare Workers

Backend API for DEALAK Real Estate Platform deployed on Cloudflare Workers.

## Tech Stack

- Cloudflare Workers
- Hono (Web Framework)
- D1 Database (SQLite)
- KV Storage (Caching)
- R2 Storage (File Storage)
- TypeScript

## Setup

### 1. Install Wrangler CLI
```bash
npm install -g wrangler
```

### 2. Login to Cloudflare
```bash
wrangler login
```

### 3. Create D1 Database
```bash
wrangler d1 create dealak-db
```

Update `wrangler.toml` with the returned `database_id`.

### 4. Create KV Namespace
```bash
wrangler kv:namespace create "CACHE"
```

Update `wrangler.toml` with the returned `id`.

### 5. Create R2 Bucket
```bash
wrangler r2 bucket create dealak-storage
```

### 6. Install Dependencies
```bash
npm install
```

### 7. Run Migrations
```bash
wrangler d1 execute dealak-db --file=../database/schema.sql
```

### 8. Seed Database
```bash
wrangler d1 execute dealak-db --file=../database/seed.sql
```

## Development

### Start Local Development Server
```bash
npm run dev
```

### Deploy to Cloudflare
```bash
npm run deploy
```

### View Logs
```bash
npm run tail
```

## API Endpoints

### Health
- `GET /` - API info
- `GET /health` - Health check

### Properties
- `GET /api/v1/properties` - List properties
- `GET /api/v1/properties/:id` - Get property details
- `GET /api/v1/search` - Search properties

### Auth
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/register` - Register

## Environment Variables

Set in `wrangler.toml` or Cloudflare dashboard:

- `ENVIRONMENT` - Environment (development/production)
- `API_VERSION` - API version

## Limitations

Cloudflare Workers has some limitations compared to traditional Node.js:

- No WebSocket support (use Server-Sent Events instead)
- 10ms CPU time limit for free tier
- 50ms CPU time limit for paid tier
- No direct PostgreSQL support (use D1 instead)
- Limited file system access

## Migration from Express

This is a simplified version of the Express backend adapted for Cloudflare Workers:

- ✅ REST API endpoints
- ✅ D1 database queries
- ✅ KV caching
- ✅ R2 file storage
- ❌ WebSocket (Socket.io not supported)
- ❌ Redis (use KV instead)
- ❌ PostgreSQL (use D1 instead)

## Next Steps

1. Implement proper JWT authentication
2. Add more API endpoints
3. Implement file upload to R2
4. Add rate limiting
5. Implement caching with KV
6. Add more comprehensive error handling
