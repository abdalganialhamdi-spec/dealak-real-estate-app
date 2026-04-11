import { Router } from 'express';
import { AuthController } from './auth.controller';
import { authMiddleware } from '../../middleware/auth.middleware';
import { validateRequest } from '../../middleware/validator';
import { registerSchema, loginSchema, forgotPasswordSchema, resetPasswordSchema } from './auth.schema';

const router = Router();
const authController = new AuthController();

// Public routes
router.post('/register', validateRequest(registerSchema), authController.register);
router.post('/login', validateRequest(loginSchema), authController.login);
router.post('/logout', authMiddleware, authController.logout);
router.post('/refresh-token', authController.refreshToken);
router.post('/forgot-password', validateRequest(forgotPasswordSchema), authController.forgotPassword);
router.post('/reset-password', validateRequest(resetPasswordSchema), authController.resetPassword);
router.get('/google', authController.googleAuth);
router.get('/google/callback', authController.googleCallback);

export { router as authRoutes };
