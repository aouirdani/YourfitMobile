import jwt from 'jsonwebtoken';
import { ENV } from '../env';

export const signToken = (payload: object, expiresIn: string | number = '1h') => {
  return jwt.sign(payload, ENV.JWT_SECRET, { expiresIn });
};

export const verifyToken = (token: string) => {
  return jwt.verify(token, ENV.JWT_SECRET);
};
