# DEALAK Frontend - Cloudflare Pages

Frontend web application for DEALAK Real Estate Platform deployed on Cloudflare Pages.

## Tech Stack

- Next.js 14
- React 18
- TypeScript
- Tailwind CSS
- Cloudflare Pages

## Deployment

### Option 1: Git Integration (Recommended)

1. Push your code to GitHub
2. Go to Cloudflare Dashboard → Pages
3. Click "Create a project"
4. Connect your GitHub repository
5. Configure build settings:
   - **Framework preset:** Next.js
   - **Build command:** `npm run build`
   - **Build output directory:** `.next`
   - **Node.js version:** `20`

6. Click "Save and Deploy"

### Option 2: Direct Upload

```bash
# Build the project
npm run build

# Deploy using Wrangler
npx wrangler pages deploy .next
```

### Option 3: CI/CD

Add `.github/workflows/deploy-pages.yml`:

```yaml
name: Deploy to Cloudflare Pages

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 20
      - run: npm ci
      - run: npm run build
      - uses: cloudflare/wrangler-action@v2
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          command: pages deploy .next --project-name=dealak-frontend
```

## Environment Variables

Set in Cloudflare Pages dashboard:

- `NEXT_PUBLIC_API_URL` - Backend API URL
- `NEXT_PUBLIC_GOOGLE_MAPS_API_KEY` - Google Maps API key
- `NEXT_PUBLIC_FIREBASE_API_KEY` - Firebase API key

## Headers & Redirects

The following files are included for Cloudflare Pages:

- `public/_headers` - Security headers
- `public/_redirects` - API proxy redirects
- `public/_routes.json` - Route configuration
- `functions/_middleware.ts` - Middleware for headers

## Features

- ✅ Global CDN
- ✅ Automatic HTTPS
- ✅ Edge caching
- ✅ Preview deployments
- ✅ Rollbacks
- ✅ Analytics

## Performance

Cloudflare Pages provides:

- 200+ edge locations worldwide
- Automatic image optimization
- Code splitting
- Tree shaking
- Minification

## Preview Deployments

Every pull request gets a preview URL for testing before merging.

## Analytics

View analytics in Cloudflare Dashboard → Pages → Analytics.

## Custom Domain

1. Go to Cloudflare Dashboard → Pages → Custom domains
2. Add your domain (e.g., `dealak.com`)
3. Update DNS records

## Limitations

- No server-side rendering (SSR) on edge
- Use static generation (SSG) instead
- API routes run on edge (limited CPU time)
