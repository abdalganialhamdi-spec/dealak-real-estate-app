import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.middleware';

const router = Router();

router.get('/', authMiddleware, (req, res) => {
  res.json({ success: true, message: 'Deals endpoint' });
});

export { router as dealsRoutes };
