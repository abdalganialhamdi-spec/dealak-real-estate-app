# 📁 DEALAK Project Files

## Root Directory

### Configuration
- `wrangler.toml` - Cloudflare Workers configuration
- `docker-compose.yml` - Docker setup for local development
- `.gitignore` - Git ignore rules
- `README.md` - Main project documentation

### Documentation
- `CLOUDFLARE.md` - Cloudflare deployment guide
- `ARCHITECTURE.md` - System architecture documentation
- `DEPLOYMENT_CHECKLIST.md` - Deployment checklist
- `QUICKSTART.md` - Quick start guide
- `NEXT_STEPS.md` - Next steps and roadmap
- `IMPLEMENTATION_PLAN.md` - 10-week implementation plan
- `FILES.md` - This file

### GitHub
- `.github/workflows/deploy-svg.yml` - GitHub Pages deployment
- `.github/workflows/deploy-cloudflare.yml` - Cloudflare deployment

## Backend Directory

### Source Code
- `backend/src/` - Main source code
  - `config/` - Configuration files
  - `modules/` - Feature modules
  - `middleware/` - Express middleware
  - `shared/` - Shared utilities
  - `jobs/` - Background jobs
  - `websocket/` - Socket.io setup
  - `app.ts` - Express app entry point

### Database
- `backend/prisma/` - Prisma ORM
  - `schema.prisma` - Database schema
  - `seed.ts` - Seed data

### Cloudflare Worker
- `backend/worker.ts` - Cloudflare Worker entry point
- `backend/package-worker.json` - Worker dependencies
- `backend/tsconfig.worker.json` - Worker TypeScript config
- `backend/.gitignore-worker` - Worker gitignore
- `backend/README-WORKER.md` - Worker documentation

### Configuration
- `backend/package.json` - Backend dependencies
- `backend/tsconfig.json` - TypeScript config
- `backend/.env.example` - Environment variables example

## Frontend Directory

### Source Code
- `frontend/src/` - Main source code
  - `app/` - Next.js App Router pages
    - `(auth)/` - Authentication pages
      - `login/` - Login page
      - `register/` - Registration page
    - `properties/` - Property pages
      - `[id]/` - Property details page
    - `search/` - Search page
    - `page.tsx` - Home page
    - `layout.tsx` - Root layout
    - `globals.css` - Global styles
  - `components/` - Reusable components
  - `hooks/` - Custom React hooks
  - `lib/` - Utilities and API client
  - `store/` - Zustand stores
  - `types/` - TypeScript types

### Configuration
- `frontend/package.json` - Frontend dependencies
- `frontend/next.config.js` - Next.js config
- `frontend/tailwind.config.ts` - Tailwind CSS config
- `frontend/tsconfig.json` - TypeScript config
- `frontend/postcss.config.js` - PostCSS config
- `frontend/.nvmrc` - Node.js version
- `frontend/.env.example` - Environment variables example

### Cloudflare Pages
- `frontend/wrangler.toml` - Pages configuration
- `frontend/public/_headers` - Security headers
- `frontend/public/_redirects` - API redirects
- `frontend/public/_routes.json` - Route configuration
- `frontend/functions/_middleware.ts` - Middleware

### Documentation
- `frontend/README.md` - Frontend documentation
- `frontend/README-CLOUDFLARE.md` - Cloudflare Pages documentation

## Mobile Directory

### Source Code
- `mobile/app/` - Expo Router pages
  - `(tabs)/` - Tab navigation
    - `index.tsx` - Home screen
    - `search.tsx` - Search screen
    - `favorites.tsx` - Favorites screen
    - `profile.tsx` - Profile screen
  - `_layout.tsx` - Root layout
  - `(tabs)/_layout.tsx` - Tab layout

### Configuration
- `mobile/package.json` - Mobile dependencies
- `mobile/app.json` - Expo configuration
- `mobile/tsconfig.json` - TypeScript config
- `mobile/.env.example` - Environment variables example

### Documentation
- `mobile/README.md` - Mobile documentation

## Database Directory

### Schemas
- `database/schema_final.dbml` - Final DBML schema
- `database/schema.sql` - D1 SQLite schema
- `database/seed.sql` - Seed data

### Documentation
- `database/AUDIT_REPORT.md` - Schema audit report
- `database/AUDIT_REPORT_KIMI.md` - Kimi audit report
- `database/schema_kroki.svg` - Visual diagram

## Docs Directory

### Analysis
- `docs/analysis.md` - Project analysis document

## Memory Directory

### Daily Notes
- `memory/2026-04-10.md` - Daily notes
- `memory/2026-04-11.md` - Daily notes

### Specialized Guides
- `memory/youtube-download-guide.md` - YouTube download guide
- `memory/kilo-cli-master-guide.md` - Kilo CLI guide
- `memory/frontend-skills.md` - Frontend skills
- `memory/seo-skills.md` - SEO skills

## Key Files Summary

### Must Read
1. `README.md` - Project overview
2. `CLOUDFLARE.md` - Deployment guide
3. `QUICKSTART.md` - Quick start
4. `NEXT_STEPS.md` - Roadmap

### Configuration
1. `wrangler.toml` - Cloudflare config
2. `docker-compose.yml` - Docker setup
3. `backend/package.json` - Backend deps
4. `frontend/package.json` - Frontend deps
5. `mobile/package.json` - Mobile deps

### Database
1. `database/schema_final.dbml` - DBML schema
2. `database/schema.sql` - D1 schema
3. `database/seed.sql` - Seed data

### Documentation
1. `ARCHITECTURE.md` - System architecture
2. `DEPLOYMENT_CHECKLIST.md` - Deployment checklist
3. `IMPLEMENTATION_PLAN.md` - Implementation plan

## File Sizes

| File | Size |
|------|------|
| `IMPLEMENTATION_PLAN.md` | ~20KB |
| `database/schema_final.dbml` | ~10KB |
| `database/schema.sql` | ~8KB |
| `database/seed.sql` | ~3KB |
| `CLOUDFLARE.md` | ~8KB |
| `ARCHITECTURE.md` | ~10KB |
| `NEXT_STEPS.md` | ~12KB |

## Total Stats

- **Total Files:** 100+
- **Total Commits:** 10
- **Documentation Files:** 15+
- **Configuration Files:** 20+
- **Source Code Files:** 50+

---

**Last Updated:** 2026-04-11
