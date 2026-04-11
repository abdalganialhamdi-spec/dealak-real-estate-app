import { Hono } from 'hono';

type Env = {
  DB: D1Database;
};

const favorites = new Hono<{ Bindings: Env }>();

favorites.get('/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    const result = await c.env.DB.prepare(
      `SELECT f.*, p.title, p.price, p.city, p.slug
       FROM favorites f
       JOIN properties p ON f.property_id = p.id
       WHERE f.user_id = ?
       ORDER BY f.created_at DESC`
    ).bind(userId).all();

    return c.json({ favorites: result.results });
  } catch (error) {
    return c.json({ error: 'Failed to get favorites' }, 500);
  }
});

favorites.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const { userId, propertyId } = body;

    const result = await c.env.DB.prepare(
      'INSERT INTO favorites (user_id, property_id) VALUES (?, ?)'
    ).bind(userId, propertyId).run();

    if (!result.success) {
      return c.json({ error: 'Failed to add favorite' }, 500);
    }

    return c.json({ message: 'Favorite added successfully' });
  } catch (error) {
    return c.json({ error: 'Failed to add favorite' }, 500);
  }
});

favorites.delete('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    await c.env.DB.prepare('DELETE FROM favorites WHERE id = ?').bind(id).run();
    return c.json({ message: 'Favorite removed successfully' });
  } catch (error) {
    return c.json({ error: 'Failed to remove favorite' }, 500);
  }
});

export default favorites;
