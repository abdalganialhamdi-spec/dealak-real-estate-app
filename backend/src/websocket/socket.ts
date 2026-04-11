import { Server as SocketIOServer, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import { config } from '../config';
import { logger } from '../shared/utils/logger';

export function setupWebSocket(io: SocketIOServer) {
  io.use(async (socket: Socket, next) => {
    try {
      const token = socket.handshake.auth.token;

      if (!token) {
        return next(new Error('Authentication error'));
      }

      const decoded = jwt.verify(token, config.jwt.secret) as { userId: bigint };

      socket.data.userId = decoded.userId;
      next();
    } catch (error) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket: Socket) => {
    const userId = socket.data.userId;
    logger.info(`User connected: ${userId}`);

    // Join user's personal room
    socket.join(`user:${userId}`);

    // Handle chat messages
    socket.on('message', (data) => {
      logger.info(`Message from user ${userId}:`, data);
      // TODO: Implement message handling
    });

    // Handle notifications
    socket.on('notification', (data) => {
      logger.info(`Notification for user ${userId}:`, data);
      // TODO: Implement notification handling
    });

    socket.on('disconnect', () => {
      logger.info(`User disconnected: ${userId}`);
    });
  });
}
