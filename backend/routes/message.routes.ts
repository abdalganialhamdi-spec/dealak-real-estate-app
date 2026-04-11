import { Hono } from 'hono';

type Env = {
  DB: D1Database;
};

const messages = new Hono<{ Bindings: Env }>();

messages.get('/conversations/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    const result = await c.env.DB.prepare(
      `SELECT c.*, u1.first_name as user1_name, u2.first_name as user2_name
       FROM conversations c
       JOIN users u1 ON c.participant1 = u1.id
       JOIN users u2 ON c.participant2 = u2.id
       WHERE c.participant1 = ? OR c.participant2 = ?
       ORDER BY c.last_message_at DESC`
    ).bind(userId, userId).all();

    return c.json({ conversations: result.results });
  } catch (error) {
    return c.json({ error: 'Failed to get conversations' }, 500);
  }
});

messages.get('/:conversationId', async (c) => {
  try {
    const conversationId = c.req.param('conversationId');
    const result = await c.env.DB.prepare(
      'SELECT * FROM messages WHERE conversation_id = ? ORDER BY created_at ASC'
    ).bind(conversationId).all();

    return c.json({ messages: result.results });
  } catch (error) {
    return c.json({ error: 'Failed to get messages' }, 500);
  }
});

messages.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const { conversationId, senderId, receiverId, content } = body;

    const result = await c.env.DB.prepare(
      'INSERT INTO messages (conversation_id, sender_id, receiver_id, content) VALUES (?, ?, ?, ?)'
    ).bind(conversationId, senderId, receiverId, content).run();

    if (!result.success) {
      return c.json({ error: 'Failed to send message' }, 500);
    }

    return c.json({ message: 'Message sent successfully' });
  } catch (error) {
    return c.json({ error: 'Failed to send message' }, 500);
  }
});

export default messages;
