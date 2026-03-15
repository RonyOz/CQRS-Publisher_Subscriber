import express, { Request, Response } from 'express';

const app = express();
const PORT = process.env.PORT || 3001;

// In-memory store for commands
interface DataItem {
  id: string;
  name: string;
  createdAt: string;
}

const store: Map<string, DataItem> = new Map();

// Middleware
app.use(express.json());

// Simple logging middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

/**
 * POST /command
 * Creates or updates a data item
 */
app.post('/command', (req: Request, res: Response) => {
  try {
    const { id, name } = req.body;

    if (!id || !name) {
      return res.status(400).json({
        error: 'Missing required fields: id, name',
      });
    }

    const item: DataItem = {
      id,
      name,
      createdAt: new Date().toISOString(),
    };

    store.set(id, item);

    console.log(`✓ Command executed: Created/Updated item ${id}`);

    res.status(201).json({
      success: true,
      message: 'Command executed successfully',
      data: item,
    });
  } catch (error) {
    console.error('Command error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * GET /command (optional)
 * Returns count of stored items (write-side read)
 */
app.get('/command/stats', (req: Request, res: Response) => {
  res.json({
    message: 'Command Service Stats (Write-side)',
    totalItems: store.size,
    items: Array.from(store.values()),
  });
});

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'Command Service is running', port: PORT });
});

// Start server
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════╗
║  COMMAND SERVICE (CQRS - Write Side)  ║
║  Running on http://localhost:${PORT}   ║
╚═══════════════════════════════════════╝
  `);
});
