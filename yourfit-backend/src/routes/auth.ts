import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { prisma } from '../prisma';

export const authRouter = Router();

authRouter.post('/register', async (req, res) => {
  try {
    const { email, password } = req.body ?? {};
    if (!email || !password) return res.status(400).json({ error: 'email_password_required' });
    const normalized = String(email).toLowerCase().trim();
    const exists = await prisma.user.findUnique({ where: { email: normalized } });
    if (exists) return res.status(409).json({ error: 'email_taken' });
    const hash = await bcrypt.hash(String(password), 10);
    const user = await prisma.user.create({ data: { email: normalized, passwordHash: hash } });
    return res.status(201).json({ success: true, userId: user.id });
  } catch (e: any) {
    console.error(e);
    return res.status(500).json({ error: 'server_error' });
  }
});
