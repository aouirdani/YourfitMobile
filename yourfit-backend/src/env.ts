if (process.env.NODE_ENV !== 'production') {
  try { require('dotenv').config(); } catch {}
}
const need = (k: string) => {
  const v = process.env[k];
  if (!v) throw new Error(`Missing env ${k}`);
  return v;
};
export const ENV = {
  PORT: Number(process.env.PORT) || 3000,
  DATABASE_URL: need('DATABASE_URL'),
  DIRECT_URL: process.env.DIRECT_URL, // utile pour prisma en job / local
  JWT: process.env.JWT_SECRET || 'dev_jwt',
};
