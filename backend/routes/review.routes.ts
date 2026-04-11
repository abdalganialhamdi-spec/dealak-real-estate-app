import { Hono } from 'hono';

type Env = {
  DB: D1Database;
};

const reviews = new Hono<{ Bindings: Env }>();

reviews.get('/property/:propertyId', async (c) => {
  try {
    const propertyId = c.req.param('propertyId');
    const result = await c.env.DB.prepare(
      `SELECT r.*, u.first_name, u.last_name
       FROM reviews r
       JOIN users u ON r.user_id = u.id
       WHERE r.property_id = ?
       ORDER BY r.created_at DESC`
    ).bind(propertyId).all();

    return c.json({ reviews: result.results });
  } catch (error) {
    return c.json({ error: 'Failed to get reviews' }, 500);
  }
});

reviews.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const { userId, propertyId, rating, comment } = body;

    const result = await c.env.DB.prepare(
      'INSERT INTO reviews (user_id, property_id, rating, comment) VALUES (?, ?, ?, ?)'
    ).bind(userId, propertyId, rating, comment).run();

    if (!result.success) {
      return c.json({ error: 'Failed to create review' }, 500);
    }

    return c.json({ message: 'Review created successfully' });
  } catch (error) {
    return c.json({ error: 'Failed to create review' }, 500);
  }
});

export default reviews;
