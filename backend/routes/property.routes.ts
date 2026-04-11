// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  DEALAK Real Estate Platform — Property Routes                          ║
// ║  Version:  1.0.0                                                       ║
// ║  Date:     11 April 2026                                               ║
// ╚══════════════════════════════════════════════════════════════════════════╝

import { Hono } from 'hono';
import { z } from 'zod';

type Env = {
  DB: D1Database;
  CACHE: KVNamespace;
};

const properties = new Hono<{ Bindings: Env }>();

// ──────────────────────────────────────────────────────────────────────────
// Get All Properties
// ──────────────────────────────────────────────────────────────────────────
properties.get('/', async (c) => {
  try {
    const { page = '1', limit = '20', city, propertyType, status, minPrice, maxPrice } = c.req.query();

    const offset = (parseInt(page) - 1) * parseInt(limit);
    let query = 'SELECT * FROM properties WHERE deleted_at IS NULL';
    const params: any[] = [];

    if (city) {
      query += ' AND city = ?';
      params.push(city);
    }

    if (propertyType) {
      query += ' AND property_type = ?';
      params.push(propertyType);
    }

    if (status) {
      query += ' AND status = ?';
      params.push(status);
    }

    if (minPrice) {
      query += ' AND price >= ?';
      params.push(parseFloat(minPrice));
    }

    if (maxPrice) {
      query += ' AND price <= ?';
      params.push(parseFloat(maxPrice));
    }

    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);

    const result = await c.env.DB.prepare(query).bind(...params).all();

    // Get images for each property
    const propertiesWithImages = await Promise.all(
      result.results.map(async (property: any) => {
        const images = await c.env.DB.prepare(
          'SELECT * FROM property_images WHERE property_id = ? ORDER BY sort_order'
        ).bind(property.id).all();
        return { ...property, images: images.results };
      })
    );

    return c.json({
      properties: propertiesWithImages,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: result.results.length,
      },
    });
  } catch (error) {
    console.error('Get properties error:', error);
    return c.json({ error: 'Failed to get properties' }, 500);
  }
});

// ──────────────────────────────────────────────────────────────────────────
// Get Property by ID
// ──────────────────────────────────────────────────────────────────────────
properties.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');

    const property = await c.env.DB.prepare(
      'SELECT * FROM properties WHERE id = ? AND deleted_at IS NULL'
    ).bind(id).first();

    if (!property) {
      return c.json({ error: 'Property not found' }, 404);
    }

    // Get images
    const images = await c.env.DB.prepare(
      'SELECT * FROM property_images WHERE property_id = ? ORDER BY sort_order'
    ).bind(id).all();

    // Get features
    const features = await c.env.DB.prepare(
      'SELECT * FROM property_features WHERE property_id = ?'
    ).bind(id).all();

    // Get owner
    const owner = await c.env.DB.prepare(
      'SELECT id, first_name, last_name, email, phone FROM users WHERE id = ?'
    ).bind(property.owner_id).first();

    // Increment view count
    await c.env.DB.prepare(
      'UPDATE properties SET view_count = view_count + 1 WHERE id = ?'
    ).bind(id).run();

    // Track view
    await c.env.DB.prepare(
      'INSERT INTO property_views (property_id, ip_address, user_agent) VALUES (?, ?, ?)'
    ).bind(id, c.req.header('CF-Connecting-IP'), c.req.header('User-Agent')).run();

    return c.json({
      property: {
        ...property,
        images: images.results,
        features: features.results,
        owner,
      },
    });
  } catch (error) {
    console.error('Get property error:', error);
    return c.json({ error: 'Failed to get property' }, 500);
  }
});

// ──────────────────────────────────────────────────────────────────────────
// Create Property
// ──────────────────────────────────────────────────────────────────────────
properties.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const {
      ownerId,
      title,
      slug,
      description,
      propertyType,
      listingType,
      price,
      currency,
      areaSqm,
      bedrooms,
      bathrooms,
      city,
      district,
      latitude,
      longitude,
      isFeatured,
      isNegotiable,
    } = body;

    const result = await c.env.DB.prepare(
      `INSERT INTO properties (owner_id, title, slug, description, property_type, listing_type, price, currency, area_sqm, bedrooms, bathrooms, city, district, latitude, longitude, is_featured, is_negotiable)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    ).bind(
      ownerId,
      title,
      slug,
      description,
      propertyType,
      listingType,
      price,
      currency || 'SYP',
      areaSqm,
      bedrooms,
      bathrooms,
      city,
      district,
      latitude,
      longitude,
      isFeatured ? 1 : 0,
      isNegotiable ? 1 : 0
    ).run();

    if (!result.success) {
      return c.json({ error: 'Failed to create property' }, 500);
    }

    const property = await c.env.DB.prepare(
      'SELECT * FROM properties WHERE id = ?'
    ).bind(result.meta.last_row_id).first();

    return c.json({
      message: 'Property created successfully',
      property,
    });
  } catch (error) {
    console.error('Create property error:', error);
    return c.json({ error: 'Failed to create property' }, 500);
  }
});

// ──────────────────────────────────────────────────────────────────────────
// Update Property
// ──────────────────────────────────────────────────────────────────────────
properties.put('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();

    const result = await c.env.DB.prepare(
      `UPDATE properties
       SET title = ?, description = ?, price = ?, area_sqm = ?, bedrooms = ?, bathrooms = ?, city = ?, district = ?, updated_at = ?
       WHERE id = ?`
    ).bind(
      body.title,
      body.description,
      body.price,
      body.areaSqm,
      body.bedrooms,
      body.bathrooms,
      body.city,
      body.district,
      new Date().toISOString(),
      id
    ).run();

    if (!result.success) {
      return c.json({ error: 'Failed to update property' }, 500);
    }

    const property = await c.env.DB.prepare(
      'SELECT * FROM properties WHERE id = ?'
    ).bind(id).first();

    return c.json({
      message: 'Property updated successfully',
      property,
    });
  } catch (error) {
    console.error('Update property error:', error);
    return c.json({ error: 'Failed to update property' }, 500);
  }
});

// ──────────────────────────────────────────────────────────────────────────
// Delete Property (Soft Delete)
// ──────────────────────────────────────────────────────────────────────────
properties.delete('/:id', async (c) => {
  try {
    const id = c.req.param('id');

    const result = await c.env.DB.prepare(
      'UPDATE properties SET deleted_at = ? WHERE id = ?'
    ).bind(new Date().toISOString(), id).run();

    if (!result.success) {
      return c.json({ error: 'Failed to delete property' }, 500);
    }

    return c.json({
      message: 'Property deleted successfully',
    });
  } catch (error) {
    console.error('Delete property error:', error);
    return c.json({ error: 'Failed to delete property' }, 500);
  }
});

export default properties;
