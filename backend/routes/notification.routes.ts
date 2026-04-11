import { Hono } from 'hono';

type Env = {
  DB: D1Database;
};

const notifications = new Hono<{ Bindings: Env }>();

notifications.get('/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    const result = await c.env.DB.prepare(
      'SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC'
    ).bind(userId).all();

    return c.json({ notifications: result.results });
  } catch (error) {
    return c.json({ error: 'Failed to get notifications' }, 500);
  }
});

notifications.put('/:id/read', async (c) => {
  try {
    const id = c.req.param('id');
    await c.env.DB.prepare(
      'UPDATE notifications SET is_read = 1, read_at = ? WHERE id = ?'
    ).bind(new Date().toISOString(), id).run();

    return c.json({ message: 'Notification marked as read' });
  } catch (error) {
    return c.json({ error: 'Failed to mark notification as read' }, 500);
  }
});

export default notifications;
