require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const winston = require('winston');

// Configure Winston logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'test-lanc-compliance' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Security middleware
app.use(helmet());
app.use(cors());

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`, {
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });
  next();
});

// Health endpoints - REQUIRED by LANC standards
app.get('/health', (req, res) => {
  const healthCheck = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: require('./package.json').version,
    environment: NODE_ENV,
    uptime: Math.floor(process.uptime()),
    memory: {
      used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + 'MB',
      total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024) + 'MB'
    },
    service: 'test-lanc-compliance'
  };
  
  res.status(200).json(healthCheck);
});

app.get('/health/readiness', (req, res) => {
  // Check if service is ready to receive traffic
  const readinessCheck = {
    status: 'ready',
    timestamp: new Date().toISOString(),
    checks: {
      database: 'healthy', // Would check actual database connection
      dependencies: 'healthy'
    }
  };
  
  res.status(200).json(readinessCheck);
});

app.get('/health/liveness', (req, res) => {
  // Check if service is alive
  const livenessCheck = {
    status: 'alive',
    timestamp: new Date().toISOString(),
    uptime: Math.floor(process.uptime())
  };
  
  res.status(200).json(livenessCheck);
});

app.get('/api/status', (req, res) => {
  // Service-specific status endpoint
  const status = {
    service: 'test-lanc-compliance',
    status: 'operational',
    timestamp: new Date().toISOString(),
    environment: NODE_ENV,
    version: require('./package.json').version,
    features: {
      healthChecks: 'enabled',
      logging: 'enabled',
      security: 'enabled'
    }
  };
  
  res.status(200).json(status);
});

// Sample API endpoint
app.get('/api/hello', (req, res) => {
  res.json({ 
    message: 'Hello from LANC-compliant test service!',
    timestamp: new Date().toISOString()
  });
});

// Structured 404 handler for undefined routes - REQUIRED by LANC standards
app.use('*', (req, res) => {
  const error = {
    error: 'Not Found',
    message: `Route ${req.method} ${req.originalUrl} not found`,
    status: 404,
    timestamp: new Date().toISOString(),
    path: req.originalUrl,
    method: req.method
  };
  
  logger.warn('404 Not Found', error);
  res.status(404).json(error);
});

// Global error handler middleware - REQUIRED by LANC standards
app.use((err, req, res, next) => {
  const status = err.status || err.statusCode || 500;
  const message = err.message || 'Internal Server Error';
  
  const errorResponse = {
    error: 'Server Error',
    message: message,
    status: status,
    timestamp: new Date().toISOString(),
    path: req.originalUrl,
    method: req.method
  };
  
  // Log error details
  logger.error('Server Error', {
    ...errorResponse,
    stack: err.stack,
    body: req.body
  });
  
  // Don't leak error details in production
  if (NODE_ENV === 'production') {
    delete errorResponse.stack;
  } else {
    errorResponse.stack = err.stack;
  }
  
  res.status(status).json(errorResponse);
});

// Graceful shutdown handling
process.on('SIGTERM', () => {
  logger.info('SIGTERM received. Shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT received. Shutting down gracefully...');
  process.exit(0);
});

// Start server
app.listen(PORT, () => {
  logger.info(`🚀 Test LANC Compliance service started`, {
    port: PORT,
    environment: NODE_ENV,
    version: require('./package.json').version,
    timestamp: new Date().toISOString()
  });
});

module.exports = app;