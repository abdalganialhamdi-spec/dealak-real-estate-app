# 🚀 Quick Start - Cloudflare Deployment

## 5-Minute Deployment Guide

### Prerequisites
- Cloudflare account
- GitHub repository
- Wrangler CLI: `npm install -g wrangler`

### Step 1: Login (30 seconds)
```bash
wrangler login
```

### Step 2: Create Database (1 minute)
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

### Step 3: Create KV (30 seconds)
```bash
wrangler kv:namespace create "CACHE"
```

Copy the `id` and update `wrangler.toml`:
```toml
[[kv_namespaces]]
binding = "CACHE"
id = "YOUR_KV_ID"
```

### Step 4: Create R2 Bucket (30 seconds)
```bash
wrangler r2 bucket create dealak-storage
```

### Step 5: Migrate Database (1 minute)
```bash
wrangler d1 execute dealak-db --file=database/schema.sql
wrangler d1 execute dealak-db --file=database/seed.sql
```

### Step 6: Deploy Worker (1 minute)
```bash
cd backend
npm install
wrangler deploy
```

### Step 7: Deploy Pages (1 minute)

1. Go to https://dash.cloudflare.com/
2. Navigate to Pages
3. Click "Create a project"
4. Connect your GitHub repository
5. Configure:
   - Framework: Next.js
   - Build command: `npm run build`
   - Output directory: `.next`
   - Node.js version: `20`
6. Click "Save and Deploy"

### Step 8: Test (30 seconds)

Test Worker:
```bash
curl https://dealak-backend.workers.dev/health
```

Test Pages:
Visit your Pages URL

## 🎉 Done!

Your DEALAK platform is now live on Cloudflare!

## 📚 Next Steps

- Read [CLOUDFLARE.md](CLOUDFLARE.md) for detailed guide
- Check [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) for complete checklist
- Configure custom domain
- Set up monitoring
- Add authentication

## 🆘 Need Help?

- Check [CLOUDFLARE.md](CLOUDFLARE.md) troubleshooting section
- View Worker logs: `wrangler tail`
- Check Pages analytics in Cloudflare dashboard

---

**Total Time:** ~5 minutes ⏱️
