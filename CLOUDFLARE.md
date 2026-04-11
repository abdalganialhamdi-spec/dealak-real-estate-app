# 🚀 DEALAK - Cloudflare Deployment Guide

Complete guide for deploying DEALAK Real Estate Platform on Cloudflare.

## 📋 Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Cloudflare Pages                     │
│              Frontend Web (Next.js)                   │
│         Global CDN + Edge Caching                    │
├─────────────────────────────────────────────────────┤
│                 Cloudflare Workers                   │
│              Backend API (Hono)                       │
│         D1 Database + KV Storage + R2               │
└─────────────────────────────────────────────────────┘
```

## 🛠️ Components

### 1. Cloudflare Workers (Backend)
- **Runtime:** Cloudflare Workers
- **Framework:** Hono
- **Database:** D1 (SQLite)
- **Cache:** KV Storage
- **Files:** R2 Storage

### 2. Cloudflare Pages (Frontend)
- **Framework:** Next.js 14
- **Deployment:** Git integration
- **Features:** Global CDN, Edge caching

## 📦 Prerequisites

1. **Cloudflare Account**
   - Sign up at https://dash.cloudflare.com/sign-up

2. **Wrangler CLI**
   ```bash
   npm install -g wrangler
   ```

3. **GitHub Repository**
   - Push code to GitHub

## 🚀 Deployment Steps

### Step 1: Setup Cloudflare Workers

#### 1.1 Login to Cloudflare
```bash
wrangler login
```

#### 1.2 Create D1 Database
```bash
wrangler d1 create dealak-db
```

Copy the `database_id` and update `wrangler.toml`:
```toml
[[d1_databases]]
binding = "DB"
database_name = "dealak-db"
database_id = "YOUR_DATABASE_ID"
```

#### 1.3 Create KV Namespace
```bash
wrangler kv:namespace create "CACHE"
```

Copy the `id` and update `wrangler.toml`:
```toml
[[kv_namespaces]]
binding = "CACHE"
id = "YOUR_KV_ID"
```

#### 1.4 Create R2 Bucket
```bash
wrangler r2 bucket create dealak-storage
```

#### 1.5 Run Migrations
```bash
wrangler d1 execute dealak-db --file=database/schema.sql
```

#### 1.6 Seed Database
```bash
wrangler d1 execute dealak-db --file=database/seed.sql
```

#### 1.7 Deploy Worker
```bash
cd backend
npm install
wrangler deploy
```

### Step 2: Setup Cloudflare Pages

#### 2.1 Connect GitHub Repository

1. Go to Cloudflare Dashboard → Pages
2. Click "Create a project"
3. Click "Connect to Git"
4. Select your repository
5. Configure build settings:
   - **Framework preset:** Next.js
   - **Build command:** `npm run build`
   - **Build output directory:** `.next`
   - **Node.js version:** `20`

6. Click "Save and Deploy"

#### 2.2 Configure Environment Variables

In Cloudflare Pages dashboard, add:

- `NEXT_PUBLIC_API_URL` - Your Worker URL (e.g., `https://dealak-backend.workers.dev`)
- `NEXT_PUBLIC_GOOGLE_MAPS_API_KEY` - Google Maps API key
- `NEXT_PUBLIC_FIREBASE_API_KEY` - Firebase API key

#### 2.3 Configure Custom Domain (Optional)

1. Go to Pages → Custom domains
2. Add your domain (e.g., `dealak.com`)
3. Update DNS records

### Step 3: Setup GitHub Actions (Optional)

#### 3.1 Add Secrets

In GitHub repository settings, add:

- `CLOUDFLARE_API_TOKEN` - Cloudflare API token
- `CLOUDFLARE_ACCOUNT_ID` - Cloudflare Account ID

#### 3.2 Enable Workflow

The workflow `.github/workflows/deploy-cloudflare.yml` will automatically deploy on push to `main`.

## 🔧 Configuration Files

### Backend (Worker)
- `wrangler.toml` - Worker configuration
- `backend/worker.ts` - Worker entry point
- `backend/package-worker.json` - Dependencies
- `backend/tsconfig.worker.json` - TypeScript config

### Frontend (Pages)
- `frontend/wrangler.toml` - Pages configuration
- `frontend/public/_headers` - Security headers
- `frontend/public/_redirects` - API redirects
- `frontend/public/_routes.json` - Route config
- `frontend/functions/_middleware.ts` - Middleware

## 📊 Monitoring

### Worker Logs
```bash
wrangler tail
```

### Pages Analytics
Go to Cloudflare Dashboard → Pages → Analytics

## 🔄 Updates

### Update Worker
```bash
cd backend
wrangler deploy
```

### Update Pages
Push to GitHub, automatic deployment triggers.

## 🧪 Testing

### Local Worker Development
```bash
cd backend
wrangler dev
```

### Local Pages Development
```bash
cd frontend
npm run dev
```

## 📝 Notes

### Limitations

Cloudflare Workers has some limitations:

- **No WebSocket support** - Use Server-Sent Events instead
- **CPU time limits** - 10ms (free) / 50ms (paid)
- **No PostgreSQL** - Use D1 (SQLite) instead
- **No Redis** - Use KV Storage instead
- **Limited file system** - Use R2 for file storage

### Migration from Express

The Worker version is a simplified version of the Express backend:

- ✅ REST API endpoints
- ✅ D1 database queries
- ✅ KV caching
- ✅ R2 file storage
- ❌ WebSocket (Socket.io not supported)
- ❌ Redis (use KV instead)
- ❌ PostgreSQL (use D1 instead)

### Performance

- **Workers:** 200+ edge locations
- **Pages:** Global CDN
- **D1:** Edge database
- **KV:** Edge key-value store
- **R2:** Object storage

## 🆘 Troubleshooting

### Worker Deployment Fails
```bash
# Check logs
wrangler tail

# Check configuration
wrangler whoami
```

### Pages Build Fails
- Check Node.js version (must be 20)
- Check build command
- Check environment variables

### Database Issues
```bash
# Check D1 database
wrangler d1 execute dealak-db --command="SELECT * FROM users LIMIT 5"
```

## 📚 Resources

- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Cloudflare Pages Docs](https://developers.cloudflare.com/pages/)
- [Wrangler CLI Docs](https://developers.cloudflare.com/workers/wrangler/)
- [Hono Framework](https://hono.dev/)
- [D1 Database](https://developers.cloudflare.com/d1/)

## 🎯 Next Steps

1. ✅ Deploy Worker to Cloudflare
2. ✅ Deploy Frontend to Cloudflare Pages
3. ✅ Configure custom domain
4. ✅ Set up monitoring
5. ✅ Implement proper authentication
6. ✅ Add more API endpoints
7. ✅ Implement file upload to R2
8. ✅ Add rate limiting
9. ✅ Implement caching with KV
10. ✅ Add comprehensive error handling

---

**Status:** Ready for deployment 🚀
