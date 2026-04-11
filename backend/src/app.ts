import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Import config
import { config } from './config';
import { logger } from './shared/utils/logger';
import { errorHandler } from './middleware/errorHandler';
import { notFoundHandler } from './middleware/notFoundHandler';

// Import routes
import { authRoutes } from './modules/auth/auth.routes';
import { usersRoutes } from './modules/users/users.routes';
import { propertiesRoutes } from './modules/properties/properties.routes';
import { dealsRoutes } from './modules/deals/deals.routes';
import { paymentsRoutes } from './modules/payments/payments.routes';
import { requestsRoutes } from './modules/requests/requests.routes';
import { messagesRoutes } from './modules/messages/messages.routes';
import { notificationsRoutes } from './modules/notifications/notifications.routes';
import { reviewsRoutes } from './modules/reviews/reviews.routes';
import { favoritesRoutes } from './modules/favorites/favorites.routes';
import { discountsRoutes } from './modules/discounts/discounts.routes';

// Import WebSocket
import { setupWebSocket } from './websocket/socket';

// Create Express app
const app: Application = express();
const httpServer = createServer(app);
const io = new SocketIOServer(httpServer, {
  cors: {
    origin: config.cors.origin,
    credentials: true,
  },
});

// Make io globally available
app.set('io', io);

// Setup WebSocket
setupWebSocket(io);

// Security middleware
app.use(helmet());
app.use(cors({
  origin: config.cors.origin,
  credentials: true,
}));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`, {
    ip: req.ip,
    userAgent: req.get('user-agent'),
  });
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/users', usersRoutes);
app.use('/api/v1/properties', propertiesRoutes);
app.use('/api/v1/deals', dealsRoutes);
app.use('/api/v1/payments', paymentsRoutes);
app.use('/api/v1/requests', requestsRoutes);
app.use('/api/v1/messages', messagesRoutes);
app.use('/api/v1/notifications', notificationsRoutes);
app.use('/api/v1/reviews', reviewsRoutes);
app.use('/api/v1/favorites', favoritesRoutes);
app.use('/api/v1/discounts', discountsRoutes);

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

// Start server
const PORT = config.port;
httpServer.listen(PORT, () => {
  logger.info(`🚀 Server running on port ${PORT}`);
  logger.info(`📚 API Documentation: http://localhost:${PORT}/api-docs`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  httpServer.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
});

export { app, io };
