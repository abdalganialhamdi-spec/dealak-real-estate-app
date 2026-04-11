// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  DEALAK Real Estate Platform — Cloudflare Worker (Hono)               ║
// ╚══════════════════════════════════════════════════════════════════════════╝

import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';

import authRoutes from './routes/auth.routes';
import propertyRoutes from './routes/property.routes';
import userRoutes from './routes/user.routes';
import favoriteRoutes from './routes/favorite.routes';
import messageRoutes from './routes/message.routes';
import dealRoutes from './routes/deal.routes';
import reviewRoutes from './routes/review.routes';
import notificationRoutes from './routes/notification.routes';

type Bindings = {
  DB: D1Database;
  CACHE: KVNamespace;
  ENVIRONMENT: string;
  APP_NAME: string;
  APP_VERSION: string;
  CURRENCY: string;
  JWT_SECRET: string;
};

const app = new Hono<{ Bindings: Bindings }>();

// ── Middleware ────────────────────────────────────────────────────────────
app.use('*', logger());
app.use('*', cors({
  origin: ['https://dealak.pages.dev', 'http://localhost:3000'],
  credentials: true,
}));

// ── Health Check ──────────────────────────────────────────────────────────
app.get('/', (c) => c.json({
  name: c.env.APP_NAME,
  version: c.env.APP_VERSION,
  environment: c.env.ENVIRONMENT,
  currency: c.env.CURRENCY,
  status: 'healthy',
  timestamp: new Date().toISOString(),
}));

app.get('/health', (c) => c.json({ status: 'ok', db: 'connected' }));

// ── API Routes ────────────────────────────────────────────────────────────
app.route('/api/auth', authRoutes);
app.route('/api/properties', propertyRoutes);
app.route('/api/users', userRoutes);
app.route('/api/favorites', favoriteRoutes);
app.route('/api/messages', messageRoutes);
app.route('/api/deals', dealRoutes);
app.route('/api/reviews', reviewRoutes);
app.route('/api/notifications', notificationRoutes);

// ── 404 ───────────────────────────────────────────────────────────────────
app.notFound((c) => c.json({ error: 'Not Found', path: c.req.path }, 404));

// ── Error Handler ─────────────────────────────────────────────────────────
app.onError((err, c) => {
  console.error('Error:', err);
  return c.json({ error: 'Internal Server Error', message: err.message }, 500);
});

export default app;
