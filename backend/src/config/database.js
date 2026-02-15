const { Sequelize } = require('sequelize');
const logger = require('./logger');

// Create Sequelize instance with PostgreSQL connection
const sequelize = new Sequelize(
    process.env.DB_NAME || 'kanban_db',
    process.env.DB_USER || 'postgres',
    process.env.DB_PASSWORD || 'password',
  {
        host: process.env.DB_HOST || 'localhost',
        port: parseInt(process.env.DB_PORT) || 5432,
        dialect: 'postgres',

        // Connection pool configuration
        pool: {
                max: parseInt(process.env.DB_POOL_MAX) || 20,
                min: parseInt(process.env.DB_POOL_MIN) || 0,
                acquire: 30000,
                idle: 10000
        },

        // Logging configuration
        logging: process.env.NODE_ENV === 'development' 
          ? (msg) => logger.debug(msg)
                : false,

        // Performance optimization
        define: {
                timestamps: true,
                underscored: true,
                freezeTableName: true
        },

        // Timezone configuration
        timezone: process.env.DB_TIMEZONE || '+00:00',

        // Query options
        query: {
                raw: false
        },

        // Retry configuration for connection issues
        retry: {
                max: 3,
                match: [
                          /SequelizeConnectionError/,
                          /SequelizeConnectionRefusedError/,
                          /SequelizeHostNotFoundError/,
                          /SequelizeHostNotReachableError/,
                          /SequelizeInvalidConnectionError/,
                          /SequelizeConnectionTimedOutError/
                        ]
        }
  }
  );

// Test database connection
const testConnection = async () => {
    try {
          await sequelize.authenticate();
          logger.info('✓ Database connection established successfully');
          logger.info(`  Database: ${process.env.DB_NAME}@${process.env.DB_HOST}:${process.env.DB_PORT}`);
          return true;
    } catch (error) {
          logger.error('✗ Unable to connect to the database:', error);
          return false;
    }
};

// Sync database (development only)
const syncDatabase = async (options = {}) => {
    try {
          if (process.env.NODE_ENV === 'production') {
                  logger.warn('Database sync is disabled in production. Use migrations instead.');
                  return false;
          }

      await sequelize.sync(options);
          logger.info(`✓ Database synchronized ${options.force ? '(forced)' : '(altered)'}`);
          return true;
    } catch (error) {
          logger.error('✗ Database sync failed:', error);
          return false;
    }
};

// Close database connection gracefully
const closeConnection = async () => {
    try {
          await sequelize.close();
          logger.info('✓ Database connection closed');
          return true;
    } catch (error) {
          logger.error('✗ Error closing database connection:', error);
          return false;
    }
};

// Export database utilities
module.exports = {
    sequelize,
    Sequelize,
    testConnection,
    syncDatabase,
    closeConnection
};
