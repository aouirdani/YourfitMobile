import prisma from '../prisma';
import { hashPassword, comparePassword } from '../utils/hash';
import { signToken } from '../utils/jwt';

export const signup = async (email: string, password: string, username?: string) => {
  const existingUser = await prisma.user.findUnique({ where: { email } });
  if (existingUser) throw new Error('Email already in use');

  const passwordHash = await hashPassword(password);

  const user = await prisma.user.create({
    data: { email, passwordHash, username },
  });

  const token = signToken({ id: user.id, email: user.email });

  return { user, token };
};

export const login = async (email: string, password: string) => {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) throw new Error('Invalid credentials');

  const valid = await comparePassword(password, user.passwordHash);
  if (!valid) throw new Error('Invalid credentials');

  const token = signToken({ id: user.id, email: user.email });

  return { user, token };
};
