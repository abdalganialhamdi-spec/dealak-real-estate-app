// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  DEALAK Real Estate Platform — Cloudflare Worker (Hono)               ║
// ║  Version:  1.0.0                                                       ║
// ║  Date:     11 April 2026                                               ║
// ╚══════════════════════════════════════════════════════════════════════════╝

import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { prettyJSON } from 'hono/pretty-json';

// Import routes
import authRoutes from './routes/auth.routes';
import propertyRoutes from './routes/property.routes';
import userRoutes from './routes/user.routes';
import favoriteRoutes from './routes/favorite.routes';
import messageRoutes from './routes/message.routes';
import dealRoutes from './routes/deal.routes';
import reviewRoutes from './routes/review.routes';
import notificationRoutes from './routes/notification.routes';

// Types
type Env = {
  DB: D1Database;
  CACHE: KVNamespace;
  STORAGE: R2Bucket;
  ENVIRONMENT: string;
  APP_NAME: string;
  APP_VERSION: string;
  CURRENCY: string;
  JWT_SECRET: string;
};

// Create Hono app
const app = new Hono<{ Bindings: Env }>();

// ──────────────────────────────────────────────────────────────────────────
// Middleware
// ──────────────────────────────────────────────────────────────────────────
app.use('*', logger());
app.use('*', prettyJSON());
app.use('*', cors({
  origin: ['https://dealak.abdalgani.com', 'http://localhost:3000'],
  credentials: true,
}));

// ──────────────────────────────────────────────────────────────────────────
// Health Check
// ──────────────────────────────────────────────────────────────────────────
app.get('/', (c) => {
  return c.json({
    name: c.env.APP_NAME,
    version: c.env.APP_VERSION,
    environment: c.env.ENVIRONMENT,
    currency: c.env.CURRENCY,
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});

app.get('/health', (c) => {
  return c.json({
    status: 'healthy',
    database: 'connected',
    cache: 'connected',
    storage: 'connected',
  });
});

// ──────────────────────────────────────────────────────────────────────────
// API Routes
// ──────────────────────────────────────────────────────────────────────────
app.route('/api/auth', authRoutes);
app.route('/api/properties', propertyRoutes);
app.route('/api/users', userRoutes);
app.route('/api/favorites', favoriteRoutes);
app.route('/api/messages', messageRoutes);
app.route('/api/deals', dealRoutes);
app.route('/api/reviews', reviewRoutes);
app.route('/api/notifications', notificationRoutes);

// ──────────────────────────────────────────────────────────────────────────
// 404 Handler
// ──────────────────────────────────────────────────────────────────────────
app.notFound((c) => {
  return c.json({
    error: 'Not Found',
    message: 'The requested resource was not found',
    path: c.req.path,
  }, 404);
});

// ──────────────────────────────────────────────────────────────────────────
// Error Handler
// ──────────────────────────────────────────────────────────────────────────
app.onError((err, c) => {
  console.error('Error:', err);
  return c.json({
    error: 'Internal Server Error',
    message: err.message || 'An unexpected error occurred',
  }, 500);
});

export default app;
