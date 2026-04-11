import { Hono } from 'hono';

type Env = {
  DB: D1Database;
};

const deals = new Hono<{ Bindings: Env }>();

deals.get('/', async (c) => {
  try {
    const result = await c.env.DB.prepare(
      `SELECT d.*, p.title as property_title, u1.first_name as buyer_name, u2.first_name as seller_name
       FROM deals d
       JOIN properties p ON d.property_id = p.id
       JOIN users u1 ON d.buyer_id = u1.id
       JOIN users u2 ON d.seller_id = u2.id
       ORDER BY d.created_at DESC`
    ).all();

    return c.json({ deals: result.results });
  } catch (error) {
    return c.json({ error: 'Failed to get deals' }, 500);
  }
});

deals.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const deal = await c.env.DB.prepare(
      'SELECT * FROM deals WHERE id = ?'
    ).bind(id).first();

    if (!deal) {
      return c.json({ error: 'Deal not found' }, 404);
    }

    return c.json({ deal });
  } catch (error) {
    return c.json({ error: 'Failed to get deal' }, 500);
  }
});

deals.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const { propertyId, buyerId, sellerId, dealType, agreedPrice, currency } = body;

    const result = await c.env.DB.prepare(
      `INSERT INTO deals (property_id, buyer_id, seller_id, deal_type, agreed_price, currency)
       VALUES (?, ?, ?, ?, ?, ?)`
    ).bind(propertyId, buyerId, sellerId, dealType, agreedPrice, currency || 'SYP').run();

    if (!result.success) {
      return c.json({ error: 'Failed to create deal' }, 500);
    }

    const deal = await c.env.DB.prepare(
      'SELECT * FROM deals WHERE id = ?'
    ).bind(result.meta.last_row_id).first();

    return c.json({ message: 'Deal created successfully', deal });
  } catch (error) {
    return c.json({ error: 'Failed to create deal' }, 500);
  }
});

export default deals;
