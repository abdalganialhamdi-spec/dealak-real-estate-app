# 🏗️ DEALAK Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENTS                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Mobile App  │  │   Web App    │  │   Admin      │     │
│  │  (React      │  │   (Next.js)  │  │   Dashboard  │     │
│  │   Native)    │  │              │  │              │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
└─────────┼──────────────────┼──────────────────┼─────────────┘
          │                  │                  │
          │ HTTPS            │ HTTPS            │ HTTPS
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼─────────────┐
│         │                  │                  │             │
│  ┌──────▼──────────────────▼──────────────────▼──────┐     │
│  │              Cloudflare Pages (Frontend)           │     │
│  │  • Global CDN                                      │     │
│  │  • Edge Caching                                    │     │
│  │  • Automatic HTTPS                                 │     │
│  │  • Image Optimization                              │     │
│  └──────────────────────┬───────────────────────────────┘     │
│                         │                                     │
│                         │ API Calls                           │
│                         │                                     │
│  ┌──────────────────────▼───────────────────────────────┐     │
│  │            Cloudflare Workers (Backend)              │     │
│  │  • Hono Framework                                   │     │
│  │  • REST API                                         │     │
│  │  • Authentication                                   │     │
│  │  • Business Logic                                   │     │
│  └──────────────────────┬───────────────────────────────┘     │
│                         │                                     │
│         ┌───────────────┼───────────────┐                     │
│         │               │               │                     │
│  ┌──────▼──────┐  ┌─────▼─────┐  ┌─────▼─────┐                │
│  │  D1 Database│  │  KV Cache  │  │  R2 Storage│               │
│  │  (SQLite)   │  │  (Key-Value)│  │  (Files)   │               │
│  │             │  │            │  │            │               │
│  │ • Users     │  │ • Sessions │  │ • Images   │               │
│  │ • Properties│  │ • Cache    │  │ • Documents│               │
│  │ • Deals     │  │ • Rate     │  │ • Media     │               │
│  │ • Messages  │  │   Limits   │  │            │               │
│  └─────────────┘  └────────────┘  └────────────┘               │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

## Technology Stack

### Frontend (Cloudflare Pages)
- **Framework:** Next.js 14
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **State:** Zustand
- **Data Fetching:** React Query
- **Forms:** React Hook Form + Zod
- **Maps:** Leaflet

### Backend (Cloudflare Workers)
- **Runtime:** Cloudflare Workers
- **Framework:** Hono
- **Language:** TypeScript
- **Database:** D1 (SQLite)
- **Cache:** KV Storage
- **Storage:** R2
- **Auth:** JWT

### Mobile (React Native)
- **Framework:** React Native 0.74
- **Build:** Expo 51
- **Navigation:** Expo Router
- **State:** Zustand
- **Forms:** React Hook Form + Zod
- **Maps:** React Native Maps

## Data Flow

### Property Search Flow
```
1. User searches for properties
   ↓
2. Frontend sends request to Worker
   ↓
3. Worker queries D1 database
   ↓
4. Results cached in KV
   ↓
5. Response returned to Frontend
   ↓
6. Frontend displays results
```

### Property Listing Flow
```
1. Seller creates property listing
   ↓
2. Frontend sends data to Worker
   ↓
3. Worker validates data
   ↓
4. Worker saves to D1 database
   ↓
5. Images uploaded to R2
   ↓
6. Property marked as available
   ↓
7. Notification sent to interested users
```

### Deal Flow
```
1. Buyer requests property
   ↓
2. Seller accepts request
   ↓
3. Deal created in D1
   ↓
4. Negotiation happens
   ↓
5. Deposit paid
   ↓
6. Contract signed
   ↓
7. Final payment
   ↓
8. Deal completed
```

## Database Schema

### Core Tables
- `users` - User accounts
- `properties` - Property listings
- `deals` - Property deals
- `payments` - Payment records
- `messages` - User messages
- `notifications` - User notifications

### Supporting Tables
- `user_devices` - User devices
- `refresh_tokens` - Auth tokens
- `property_features` - Property features
- `property_images` - Property images
- `favorites` - User favorites
- `saved_searches` - Saved searches
- `requests` - Property requests
- `discounts` - Discount codes
- `conversations` - Message conversations
- `reviews` - User reviews
- `property_views` - Property views
- `audit_logs` - Audit logs
- `system_settings` - System settings

## API Endpoints

### Properties
- `GET /api/v1/properties` - List properties
- `GET /api/v1/properties/:id` - Get property details
- `POST /api/v1/properties` - Create property
- `PUT /api/v1/properties/:id` - Update property
- `DELETE /api/v1/properties/:id` - Delete property

### Search
- `GET /api/v1/search` - Search properties

### Auth
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/register` - Register
- `POST /api/v1/auth/logout` - Logout
- `POST /api/v1/auth/refresh` - Refresh token

### Users
- `GET /api/v1/users/:id` - Get user profile
- `PUT /api/v1/users/:id` - Update user profile

### Deals
- `GET /api/v1/deals` - List deals
- `GET /api/v1/deals/:id` - Get deal details
- `POST /api/v1/deals` - Create deal
- `PUT /api/v1/deals/:id` - Update deal

### Messages
- `GET /api/v1/conversations` - List conversations
- `GET /api/v1/conversations/:id/messages` - Get messages
- `POST /api/v1/messages` - Send message

### Notifications
- `GET /api/v1/notifications` - List notifications
- `PUT /api/v1/notifications/:id/read` - Mark as read

## Security

### Authentication
- JWT tokens
- Refresh token rotation
- Password hashing (bcrypt)
- Session management

### Authorization
- Role-based access control
- Resource ownership checks
- API rate limiting

### Data Protection
- HTTPS everywhere
- Input validation
- SQL injection prevention
- XSS protection
- CSRF protection

## Performance

### Caching Strategy
- KV cache for frequently accessed data
- CDN for static assets
- Image optimization
- Code splitting

### Database Optimization
- Indexed queries
- Query optimization
- Connection pooling
- Read replicas (future)

### Edge Computing
- Workers run at edge
- Low latency
- Global distribution

## Scalability

### Horizontal Scaling
- Workers auto-scale
- Pages auto-scale
- D1 scales automatically

### Vertical Scaling
- Upgrade to paid plans
- More CPU time
- More storage

### Future Enhancements
- Add WebSocket support (alternative)
- Implement real-time updates
- Add analytics
- Implement A/B testing

## Monitoring

### Logging
- Worker logs via `wrangler tail`
- Pages analytics
- Error tracking

### Metrics
- Response times
- Error rates
- User engagement
- Conversion rates

### Alerts
- Error rate thresholds
- Performance degradation
- Security incidents

## Deployment

### Environments
- Development
- Staging
- Production

### CI/CD
- GitHub Actions
- Automatic deployment
- Rollback capability

### Backup
- D1 database exports
- R2 bucket backups
- Git version control

---

**Last Updated:** 2026-04-11
