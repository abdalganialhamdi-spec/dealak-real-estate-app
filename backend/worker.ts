import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { prettyJSON } from 'hono/pretty-json';

type Env = {
  DB: D1Database;
  CACHE: KVNamespace;
  STORAGE: R2Bucket;
};

const app = new Hono<{ Bindings: Env }>();

// Middleware
app.use('*', cors());
app.use('*', logger());
app.use('*', prettyJSON());

// Health check
app.get('/', (c) => {
  return c.json({
    name: 'DEALAK API',
    version: '1.0.0',
    status: 'healthy',
    timestamp: new Date().toISOString(),
  });
});

app.get('/health', (c) => {
  return c.json({ status: 'ok' });
});

// API Routes
app.get('/api/v1/properties', async (c) => {
  const db = c.env.DB;
  
  try {
    const result = await db.prepare(`
      SELECT * FROM properties 
      WHERE status = 'available'
      ORDER BY created_at DESC
      LIMIT 20
    `).all();
    
    return c.json({
      success: true,
      data: result.results,
    });
  } catch (error) {
    return c.json({
      success: false,
      error: 'Failed to fetch properties',
    }, 500);
  }
});

app.get('/api/v1/properties/:id', async (c) => {
  const db = c.env.DB;
  const id = c.req.param('id');
  
  try {
    const result = await db.prepare(`
      SELECT * FROM properties 
      WHERE id = ?
    `).bind(id).first();
    
    if (!result) {
      return c.json({
        success: false,
        error: 'Property not found',
      }, 404);
    }
    
    return c.json({
      success: true,
      data: result,
    });
  } catch (error) {
    return c.json({
      success: false,
      error: 'Failed to fetch property',
    }, 500);
  }
});

// Search properties
app.get('/api/v1/search', async (c) => {
  const db = c.env.DB;
  const { type, listing_type, governorate, min_price, max_price, min_area, max_area } = c.req.query();
  
  let query = 'SELECT * FROM properties WHERE status = "available"';
  const params: any[] = [];
  
  if (type) {
    query += ' AND type = ?';
    params.push(type);
  }
  
  if (listing_type) {
    query += ' AND listing_type = ?';
    params.push(listing_type);
  }
  
  if (governorate) {
    query += ' AND governorate = ?';
    params.push(governorate);
  }
  
  if (min_price) {
    query += ' AND price >= ?';
    params.push(min_price);
  }
  
  if (max_price) {
    query += ' AND price <= ?';
    params.push(max_price);
  }
  
  if (min_area) {
    query += ' AND area >= ?';
    params.push(min_area);
  }
  
  if (max_area) {
    query += ' AND area <= ?';
    params.push(max_area);
  }
  
  query += ' ORDER BY created_at DESC LIMIT 50';
  
  try {
    let stmt = db.prepare(query);
    params.forEach((param, index) => {
      stmt = stmt.bind(param);
    });
    
    const result = await stmt.all();
    
    return c.json({
      success: true,
      data: result.results,
    });
  } catch (error) {
    return c.json({
      success: false,
      error: 'Failed to search properties',
    }, 500);
  }
});

// Auth endpoints (simplified)
app.post('/api/v1/auth/login', async (c) => {
  const { email, password } = await c.req.json();
  
  // TODO: Implement proper authentication
  // This is a placeholder - you need to implement JWT generation
  
  return c.json({
    success: true,
    data: {
      token: 'placeholder-jwt-token',
      user: {
        id: 1,
        email,
        name: 'User',
      },
    },
  });
});

app.post('/api/v1/auth/register', async (c) => {
  const { email, password, firstName, lastName, phone, role } = await c.req.json();
  
  const db = c.env.DB;
  
  try {
    const result = await db.prepare(`
      INSERT INTO users (email, password_hash, first_name, last_name, phone, role)
      VALUES (?, ?, ?, ?, ?, ?)
    `).bind(email, password, firstName, lastName, phone, role).run();
    
    return c.json({
      success: true,
      data: {
        id: result.meta.last_row_id,
        email,
        firstName,
        lastName,
      },
    });
  } catch (error) {
    return c.json({
      success: false,
      error: 'Failed to create user',
    }, 500);
  }
});

// 404 handler
app.notFound((c) => {
  return c.json({
    success: false,
    error: 'Not found',
  }, 404);
});

// Error handler
app.onError((err, c) => {
  console.error(err);
  return c.json({
    success: false,
    error: 'Internal server error',
  }, 500);
});

export default app;
