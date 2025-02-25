import { Sequelize } from 'sequelize-typescript';

import dotenv from 'dotenv';
import { getRootDir } from '../utils/utils';
dotenv.config();

const sequelize = new Sequelize({
  dialect: 'postgres',
  host: process.env.DB_HOST,
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT),
  models: [getRootDir(__dirname).substring(1) + '/src/models'], // Models directory
  logging: false,
});



export default sequelize;