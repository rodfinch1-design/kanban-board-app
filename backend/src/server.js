require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const cookieParser = require('cookie-parser');
const session = require('express-session');
const RedisStore = require('connect-redis').default;
const { createClient } = require('redis');
const http = require('http');
const socketIO = require('socket.io');
const rateLimit = require('express-rate-limit');

// Import configurations
const { sequelize } = require('./config/database');
const logger = require('./config/logger');

// Import routes
const authRoutes = require('./routes/auth');
const boardRoutes = require('./routes/boards');
const taskRoutes = require('./routes/tasks');
const userRoutes = require('./routes/users');

// Initialize Express app
const app = express();
const server = http.createServer(app);

// Socket.IO setup
const io = socketIO(server, {
    cors: {
          origin: process.env.FRONTEND_URL || 'http://localhost:3000',
          methods: ['GET', 'POST'],
          credentials: true
    }
});

// Redis client setup for session management
let redisClient;
if (process.env.REDIS_ENABLED === 'true') {
    redisClient = createClient({
          url: process.env.REDIS_URL || 'redis://localhost:6379'
    });

  redisClient.connect().catch(err => {
        logger.error('Redis connection error:', err);
  });
}

// Security middleware
app.use(helmet({
    contentSecurityPolicy: {
          directives: {
                  defaultSrc: ["'self'"],
                  styleSrc: ["'self'", "'unsafe-inline'"],
                  scriptSrc: ["'self'"],
                  imgSrc: ["'self'", 'data:', 'https:'],
          },
    },
}));

// CORS configuration
app.use(cors({
    origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// Rate limiting
const limiter = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
    message: 'Too many requests from this IP, please try again later.'
});

app.use('/api/', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(cookieParser());
app.use(compression());

// Logging
if (process.env.NODE_ENV !== 'test') {
    app.use(morgan('combined', { stream: logger.stream }));
}

// Session configuration
if (redisClient) {
    app.use(session({
          store: new RedisStore({ client: redisClient }),
          secret: process.env.SESSION_SECRET || 'your-session-secret',
          resave: false,
          saveUninitialized: false,
          cookie: {
                  secure: process.env.NODE_ENV === 'production',
                  httpOnly: true,
                  maxAge: 1000 * 60 * 60 * 24 // 24 hours
          }
    }));
} else {
    app.use(session({
          secret: process.env.SESSION_SECRET || 'your-session-secret',
          resave: false,
          saveUninitialized: false,
          cookie: {
                  secure: process.env.NODE_ENV === 'production',
                  httpOnly: true,
                  maxAge: 1000 * 60 * 60 * 24
          }
    }));
}

// Make io accessible to routes
app.set('io', io);

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({ 
                             status: 'ok', 
          timestamp: new Date().toISOString(),
          environment: process.env.NODE_ENV
    });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/boards', boardRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/users', userRoutes);

// Root endpoint
app.get('/', (req, res) => {
    res.json({ 
                 message: 'Kanban Board API', 
          version: '1.0.0',
          docs: '/api/docs'
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ 
                             error: 'Not Found',
          message: `Cannot ${req.method} ${req.path}`
    });
});

// Global error handler
app.use((err, req, res, next) => {
    logger.error('Error:', {
          message: err.message,
          stack: err.stack,
          url: req.url,
          method: req.method
    });

          res.status(err.status || 500).json({
                error: process.env.NODE_ENV === 'production' 
                  ? 'Internal Server Error' 
                  : err.message,
                ...(process.env.NODE_ENV !== 'production' && { stack: err.stack })
          });
});

// Socket.IO connection handling
io.on('connection', (socket) => {
    logger.info(`New socket connection: ${socket.id}`);

        socket.on('join-board', (boardId) => {
              socket.join(`board-${boardId}`);
              logger.info(`Socket ${socket.id} joined board ${boardId}`);
        });

        socket.on('leave-board', (boardId) => {
              socket.leave(`board-${boardId}`);
              logger.info(`Socket ${socket.id} left board ${boardId}`);
        });

        socket.on('disconnect', () => {
              logger.info(`Socket disconnected: ${socket.id}`);
        });
});

// Database connection and server startup
const PORT = process.env.PORT || 5000;

const startServer = async () => {
    try {
          // Test database connection
      await sequelize.authenticate();
          logger.info('Database connection established successfully');

      // Sync database models (use migrations in production)
      if (process.env.NODE_ENV === 'development') {
              await sequelize.sync({ alter: true });
              logger.info('Database models synchronized');
      }

      // Start server
      server.listen(PORT, () => {
              logger.info(`Server running on port ${PORT}`);
              logger.info(`Environment: ${process.env.NODE_ENV}`);
              logger.info(`Database: ${process.env.DB_NAME}@${process.env.DB_HOST}:${process.env.DB_PORT}`);
      });
    } catch (error) {
          logger.error('Failed to start server:', error);
          process.exit(1);
    }
};

// Handle graceful shutdown
process.on('SIGTERM', async () => {
    logger.info('SIGTERM signal received: closing HTTP server');
    server.close(async () => {
          logger.info('HTTP server closed');

                     if (redisClient) {
                             await redisClient.quit();
                             logger.info('Redis connection closed');
                     }

                     await sequelize.close();
          logger.info('Database connection closed');
          process.exit(0);
    });
});

// Start the server
if (require.main === module) {
    startServer();
}

module.exports = { app, server, io };
