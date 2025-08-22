import jwt, { SignOptions } from 'jsonwebtoken';
import { ENV } from '../env';

const SECRET = ENV.JWT_SECRET as string;

export const signToken = (payload: object, expiresIn: string | number = '1h'): string => {
  const options: SignOptions = { expiresIn };
  return jwt.sign(payload, SECRET, options);
};

export const verifyToken = (token: string) => {
  return jwt.verify(token, SECRET) as object;
};
