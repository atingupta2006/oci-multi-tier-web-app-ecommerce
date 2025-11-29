import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { randomUUID } from 'crypto';
import SQLiteAdapter from '../adapters/database/sqlite';

const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET || 'change-this-secret';
const JWT_EXPIRY = process.env.JWT_EXPIRY || '1h';
const JWT_REFRESH_EXPIRY = process.env.JWT_REFRESH_EXPIRY || '7d';

let db: SQLiteAdapter;

if (process.env.DATABASE_TYPE === 'sqlite') {
  db = new SQLiteAdapter({
    path: process.env.DATABASE_PATH || './bharatmart.db',
  });
}

function generateToken(userId: string, role: string): string {
  return jwt.sign({ userId, role }, JWT_SECRET, { expiresIn: JWT_EXPIRY } as jwt.SignOptions);
}

function generateRefreshToken(userId: string): string {
  return jwt.sign({ userId }, JWT_SECRET, { expiresIn: JWT_REFRESH_EXPIRY } as jwt.SignOptions);
}

router.post('/signup', async (req, res) => {
  try {
    const { email, password, full_name, phone } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const existingUser = db.queryOne('SELECT id FROM users WHERE email = ?', [email]);

    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const userId = randomUUID();

    db.execute(
      'INSERT INTO users (id, email, password, full_name, phone, role) VALUES (?, ?, ?, ?, ?, ?)',
      [userId, email, hashedPassword, full_name || null, phone || null, 'customer']
    );

    const token = generateToken(userId, 'customer');
    const refreshToken = generateRefreshToken(userId);

    const user = db.queryOne('SELECT id, email, role, full_name, phone FROM users WHERE id = ?', [userId]);

    res.status(201).json({
      user,
      token,
      refreshToken,
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ error: 'Signup failed' });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = db.queryOne<any>('SELECT * FROM users WHERE email = ?', [email]);

    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const validPassword = await bcrypt.compare(password, user.password);

    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = generateToken(user.id, user.role);
    const refreshToken = generateRefreshToken(user.id);

    const { password: _, ...userWithoutPassword } = user;

    res.json({
      user: userWithoutPassword,
      token,
      refreshToken,
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ error: 'Refresh token required' });
    }

    const decoded = jwt.verify(refreshToken, JWT_SECRET) as any;
    const user = db.queryOne<any>('SELECT id, role FROM users WHERE id = ?', [decoded.userId]);

    if (!user) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    const newToken = generateToken(user.id, user.role);
    const newRefreshToken = generateRefreshToken(user.id);

    res.json({
      token: newToken,
      refreshToken: newRefreshToken,
    });
  } catch (error) {
    console.error('Token refresh error:', error);
    res.status(401).json({ error: 'Invalid refresh token' });
  }
});

router.post('/logout', (req, res) => {
  res.json({ message: 'Logged out successfully' });
});

router.get('/me', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, JWT_SECRET) as any;

    const user = db.queryOne<any>(
      'SELECT id, email, role, full_name, phone, address, created_at FROM users WHERE id = ?',
      [decoded.userId]
    );

    if (!user) {
      return res.status(401).json({ error: 'User not found' });
    }

    res.json({ user });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(401).json({ error: 'Invalid token' });
  }
});

export default router;
