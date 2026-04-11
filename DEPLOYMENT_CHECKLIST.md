# ✅ Deployment Checklist - Cloudflare

## Pre-Deployment

- [ ] Have Cloudflare account
- [ ] Have GitHub repository
- [ ] Have Wrangler CLI installed
- [ ] Have Node.js 20 installed

## Backend (Workers)

### Setup
- [ ] Login to Cloudflare: `wrangler login`
- [ ] Create D1 database: `wrangler d1 create dealak-db`
- [ ] Update `wrangler.toml` with database_id
- [ ] Create KV namespace: `wrangler kv:namespace create "CACHE"`
- [ ] Update `wrangler.toml` with KV id
- [ ] Create R2 bucket: `wrangler r2 bucket create dealak-storage`

### Database
- [ ] Run migrations: `wrangler d1 execute dealak-db --file=database/schema.sql`
- [ ] Seed database: `wrangler d1 execute dealak-db --file=database/seed.sql`
- [ ] Verify data: `wrangler d1 execute dealak-db --command="SELECT * FROM users LIMIT 5"`

### Deployment
- [ ] Install dependencies: `cd backend && npm install`
- [ ] Deploy worker: `wrangler deploy`
- [ ] Test API: `curl https://dealak-backend.workers.dev/health`

## Frontend (Pages)

### Setup
- [ ] Connect GitHub repository to Cloudflare Pages
- [ ] Configure build settings:
  - [ ] Framework: Next.js
  - [ ] Build command: `npm run build`
  - [ ] Output directory: `.next`
  - [ ] Node.js version: `20`

### Environment Variables
- [ ] Add `NEXT_PUBLIC_API_URL` (Worker URL)
- [ ] Add `NEXT_PUBLIC_GOOGLE_MAPS_API_KEY`
- [ ] Add `NEXT_PUBLIC_FIREBASE_API_KEY`

### Deployment
- [ ] Trigger deployment (push to main)
- [ ] Verify deployment in Cloudflare dashboard
- [ ] Test frontend: Visit Pages URL

## GitHub Actions (Optional)

### Setup
- [ ] Add `CLOUDFLARE_API_TOKEN` to GitHub secrets
- [ ] Add `CLOUDFLARE_ACCOUNT_ID` to GitHub secrets
- [ ] Enable workflow in repository settings

### Test
- [ ] Push to main branch
- [ ] Verify Worker deployment
- [ ] Verify Pages deployment

## Post-Deployment

### Testing
- [ ] Test health endpoint: `GET /health`
- [ ] Test properties endpoint: `GET /api/v1/properties`
- [ ] Test search endpoint: `GET /api/v1/search`
- [ ] Test frontend loads
- [ ] Test frontend connects to API

### Monitoring
- [ ] Set up Worker logs: `wrangler tail`
- [ ] Check Pages analytics
- [ ] Monitor error rates
- [ ] Set up alerts

### Custom Domain (Optional)
- [ ] Add custom domain in Pages
- [ ] Update DNS records
- [ ] Verify SSL certificate
- [ ] Test custom domain

## Troubleshooting

### Worker Issues
- [ ] Check logs: `wrangler tail`
- [ ] Verify configuration: `wrangler whoami`
- [ ] Check database connection
- [ ] Verify environment variables

### Pages Issues
- [ ] Check build logs
- [ ] Verify Node.js version
- [ ] Check environment variables
- [ ] Verify build command

### Database Issues
- [ ] Check D1 status
- [ ] Verify migrations ran
- [ ] Check seed data
- [ ] Test queries manually

## Security

- [ ] Enable rate limiting
- [ ] Add authentication
- [ ] Enable HTTPS (automatic)
- [ ] Set up CORS properly
- [ ] Add security headers
- [ ] Monitor for vulnerabilities

## Performance

- [ ] Enable caching
- [ ] Optimize images
- [ ] Minimize bundle size
- [ ] Use CDN (automatic)
- [ ] Monitor load times

## Backup

- [ ] Export D1 database regularly
- [ ] Backup R2 bucket
- [ ] Keep code in Git
- [ ] Document configuration

## Documentation

- [ ] Update API documentation
- [ ] Document deployment process
- [ ] Create runbook
- [ ] Document troubleshooting steps

---

**Status:** Ready for deployment 🚀

**Next Steps:**
1. Follow the checklist above
2. Deploy to Cloudflare
3. Test thoroughly
4. Monitor performance
5. Iterate and improve
