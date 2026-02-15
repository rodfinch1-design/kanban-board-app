const winston = require('winston');
const path = require('path');
const fs = require('fs');

// Ensure logs directory exists
const logsDir = path.join(process.cwd(), 'logs');
if (!fs.existsSync(logsDir)) {
    fs.mkdirSync(logsDir, { recursive: true });
}

// Define log levels
const levels = {
    error: 0,
    warn: 1,
    info: 2,
    http: 3,
    debug: 4,
};

// Define colors for each level
const colors = {
    error: 'red',
    warn: 'yellow',
    info: 'green',
    http: 'magenta',
    debug: 'blue',
};

winston.addColors(colors);

// Define log format
const format = winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.errors({ stack: true }),
    winston.format.splat(),
    winston.format.json()
  );

// Define format for console output
const consoleFormat = winston.format.combine(
    winston.format.colorize({ all: true }),
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.printf(
          (info) => `${info.timestamp} ${info.level}: ${info.message}`
        )
  );

// Define which transports the logger should use
const transports = [
    // Console transport
    new winston.transports.Console({
          format: consoleFormat,
    }),

    // Error log file
    new winston.transports.File({
          filename: path.join(logsDir, 'error.log'),
          level: 'error',
          maxsize: 5242880, // 5MB
          maxFiles: 5,
    }),

    // Combined log file
    new winston.transports.File({
          filename: path.join(logsDir, 'combined.log'),
          maxsize: 5242880, // 5MB
          maxFiles: 5,
    }),
  ];

// Create the logger
const logger = winston.createLogger({
    level: process.env.LOG_LEVEL || (process.env.NODE_ENV === 'development' ? 'debug' : 'info'),
    levels,
    format,
    transports,
    exitOnError: false,
});

// Create a stream object for Morgan HTTP logger
logger.stream = {
    write: (message) => {
          logger.http(message.trim());
    },
};

// Add methods for different log levels
logger.logInfo = (message, meta = {}) => {
    logger.info(message, meta);
};

logger.logError = (message, error = null) => {
    if (error) {
          logger.error(message, { 
                             error: error.message, 
                  stack: error.stack 
          });
    } else {
          logger.error(message);
    }
};

logger.logWarn = (message, meta = {}) => {
    logger.warn(message, meta);
};

logger.logDebug = (message, meta = {}) => {
    logger.debug(message, meta);
};

// Handle unhandled rejections
process.on('unhandledRejection', (reason, promise) => {
    logger.error('Unhandled Rejection at:', { promise, reason });
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
    logger.error('Uncaught Exception:', { 
                     error: error.message, 
          stack: error.stack 
    });
    process.exit(1);
});

module.exports = logger;
