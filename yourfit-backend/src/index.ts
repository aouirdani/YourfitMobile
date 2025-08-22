import express from 'express';
import cors from 'cors';
import { ENV } from './env';
import authRoutes from './routes/auth';

const app = express();

app.use(cors());
app.use(express.json());

app.use('/auth', authRoutes);

app.listen(ENV.PORT, () => {
  console.log(`Server running on port ${ENV.PORT}`);
});
