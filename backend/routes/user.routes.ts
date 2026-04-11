import { Hono } from 'hono';

type Env = {
  DB: D1Database;
};

const users = new Hono<{ Bindings: Env }>();

users.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const user = await c.env.DB.prepare(
      'SELECT id, email, first_name, last_name, role, avatar_url, bio, is_verified FROM users WHERE id = ?'
    ).bind(id).first();

    if (!user) {
      return c.json({ error: 'User not found' }, 404);
    }

    return c.json({ user });
  } catch (error) {
    return c.json({ error: 'Failed to get user' }, 500);
  }
});

export default users;
