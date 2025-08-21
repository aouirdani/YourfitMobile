import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { ENV } from './env';
import { authRouter } from './routes/auth';

const app = express();
app.set('trust proxy', 1);
app.use(helmet());
app.use(cors({ origin: true }));
app.use(express.json({ limit: '1mb' }));

app.get('/health', (_req, res) => res.json({ ok: true }));
app.use('/api/auth', authRouter);

app.use((_req, res) => res.status(404).json({ error: 'not_found' }));
app.use((err: any, _req: any, res: any, _next: any) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ code: 'server_error', message: 'Unexpected error' });
});

const PORT = ENV.PORT;
console.log('Booting API with PORT=', PORT, 'NODE_ENV=', process.env.NODE_ENV);
app.listen(PORT, '0.0.0.0', () => console.log(`API on :${PORT}`));
