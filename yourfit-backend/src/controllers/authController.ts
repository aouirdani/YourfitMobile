import { Request, Response } from 'express';
import * as authService from '../services/authService';
import { prisma } from '../prisma/prisma'; // ou ton ORM / service de DB


export const signup = async (req: Request, res: Response) => {
  try {
    const { email, password, username } = req.body;
    const result = await authService.signup(email, password, username);
    res.status(201).json({ success: true, ...result });
  } catch (err: any) {
    res.status(400).json({ success: false, message: err.message });
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;
    const result = await authService.login(email, password);
    res.status(200).json({ success: true, ...result });
  } catch (err: any) {
    res.status(400).json({ success: false, message: err.message });
  }
};

export const checkEmail = async (req: Request, res: Response) => {
  try {
    const { email } = req.query;
    if (!email || typeof email !== 'string') {
      return res.status(400).json({ error: 'Email is required' });
    }

    const user = await prisma.user.findUnique({
      where: { email },
    });

    return res.json({ exists: !!user });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
};