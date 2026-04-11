// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  DEALAK Real Estate Platform — Auth Routes                              ║
// ║  Version:  1.0.0                                                       ║
// ║  Date:     11 April 2026                                               ║
// ╚══════════════════════════════════════════════════════════════════════════╝

import { Hono } from 'hono';
import { z } from 'zod';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

type Env = {
  DB: D1Database;
  CACHE: KVNamespace;
  JWT_SECRET: string;
};

const auth = new Hono<{ Bindings: Env }>();

// ──────────────────────────────────────────────────────────────────────────
// Validation Schemas
// ──────────────────────────────────────────────────────────────────────────
const registerSchema = z.object({
  email: z.string().email(),
  phone: z.string().optional(),
  password: z.string().min(6),
  firstName: z.string().min(2),
  lastName: z.string().min(2),
  role: z.enum(['BUYER', 'SELLER', 'AGENT', 'LANDLORD', 'TENANT']).optional(),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string(),
});

// ──────────────────────────────────────────────────────────────────────────
// Register
// ──────────────────────────────────────────────────────────────────────────
auth.post('/register', async (c) => {
  try {
    const body = await c.req.json();
    const validated = registerSchema.parse(body);

    // Check if user exists
    const existingUser = await c.env.DB.prepare(
      'SELECT id FROM users WHERE email = ?'
    ).bind(validated.email).first();

    if (existingUser) {
      return c.json({ error: 'User already exists' }, 400);
    }

    // Hash password
    const passwordHash = await bcrypt.hash(validated.password, 10);

    // Create user
    const result = await c.env.DB.prepare(
      `INSERT INTO users (email, phone, password_hash, first_name, last_name, role)
       VALUES (?, ?, ?, ?, ?, ?)`
    ).bind(
      validated.email,
      validated.phone || null,
      passwordHash,
      validated.firstName,
      validated.lastName,
      validated.role || 'BUYER'
    ).run();

    if (!result.success) {
      return c.json({ error: 'Failed to create user' }, 500);
    }

    // Get created user
    const user = await c.env.DB.prepare(
      'SELECT id, email, first_name, last_name, role FROM users WHERE id = ?'
    ).bind(result.meta.last_row_id).first();

    // Generate JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email, role: user.role },
      c.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    return c.json({
      message: 'User registered successfully',
      user,
      token,
    });
  } catch (error) {
    console.error('Register error:', error);
    return c.json({ error: 'Registration failed' }, 500);
  }
});

// ──────────────────────────────────────────────────────────────────────────
// Login
// ──────────────────────────────────────────────────────────────────────────
auth.post('/login', async (c) => {
  try {
    const body = await c.req.json();
    const validated = loginSchema.parse(body);

    // Get user
    const user = await c.env.DB.prepare(
      'SELECT * FROM users WHERE email = ? AND is_active = 1'
    ).bind(validated.email).first();

    if (!user) {
      return c.json({ error: 'Invalid credentials' }, 401);
    }

    // Verify password
    const isValid = await bcrypt.compare(validated.password, user.password_hash);
    if (!isValid) {
      return c.json({ error: 'Invalid credentials' }, 401);
    }

    // Update last login
    await c.env.DB.prepare(
      'UPDATE users SET last_login_at = ? WHERE id = ?'
    ).bind(new Date().toISOString(), user.id).run();

    // Generate JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email, role: user.role },
      c.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    return c.json({
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        role: user.role,
      },
      token,
    });
  } catch (error) {
    console.error('Login error:', error);
    return c.json({ error: 'Login failed' }, 500);
  }
});

// ──────────────────────────────────────────────────────────────────────────
// Get Current User
// ──────────────────────────────────────────────────────────────────────────
auth.get('/me', async (c) => {
  try {
    const authHeader = c.req.header('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return c.json({ error: 'Unauthorized' }, 401);
    }

    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, c.env.JWT_SECRET) as any;

    const user = await c.env.DB.prepare(
      'SELECT id, email, first_name, last_name, role, avatar_url, bio, is_verified FROM users WHERE id = ?'
    ).bind(decoded.userId).first();

    if (!user) {
      return c.json({ error: 'User not found' }, 404);
    }

    return c.json({ user });
  } catch (error) {
    console.error('Get user error:', error);
    return c.json({ error: 'Failed to get user' }, 500);
  }
});

export default auth;
