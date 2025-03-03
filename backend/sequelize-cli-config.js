// sequelize-cli-config.js
require('dotenv').config();

module.exports = {
  development: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'postgres',
    // If you want logging:
    // logging: console.log
  },
  // if you have other environments, add them here (test, production, etc.)
};
