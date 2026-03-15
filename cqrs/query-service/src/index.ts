import express, { Request, Response } from 'express';
import axios from 'axios';

const app = express();
const PORT = process.env.PORT || 3002;
const COMMAND_SERVICE_URL = process.env.COMMAND_SERVICE_URL || 'http://localhost:3001';

// Middleware
app.use(express.json());

// Simple logging middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

/**
 * GET /query
 * Reads data from Command Service (follows CQRS pattern)
 */
app.get('/query', async (req: Request, res: Response) => {
  try {
    console.log(`→ Fetching data from Command Service at ${COMMAND_SERVICE_URL}`);

    const response = await axios.get(`${COMMAND_SERVICE_URL}/command/stats`);

    res.json({
      message: 'Query Service Response (Read-side)',
      queryTime: new Date().toISOString(),
      data: response.data,
    });
  } catch (error) {
    console.error('Query error:', error);
    res.status(503).json({
      error: 'Cannot reach Command Service',
      details: `Make sure Command Service is running at ${COMMAND_SERVICE_URL}`,
    });
  }
});

/**
 * GET /query/:id
 * Reads a specific item
 */
app.get('/query/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    console.log(`→ Fetching item ${id} from Command Service`);

    const response = await axios.get(`${COMMAND_SERVICE_URL}/command/stats`);

    const items = response.data.items || [];
    const item = items.find((i: any) => i.id === id);

    if (!item) {
      return res.status(404).json({
        error: 'Item not found',
        id,
      });
    }

    res.json({
      message: 'Query Service Response (Read-side)',
      queryTime: new Date().toISOString(),
      data: item,
    });
  } catch (error) {
    console.error('Query error:', error);
    res.status(503).json({
      error: 'Cannot reach Command Service',
    });
  }
});

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'Query Service is running', port: PORT });
});

// Start server
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════╗
║  QUERY SERVICE (CQRS - Read Side)     ║
║  Running on http://localhost:${PORT}   ║
║  Reading from: ${COMMAND_SERVICE_URL}   ║
╚═══════════════════════════════════════╝
  `);
});
