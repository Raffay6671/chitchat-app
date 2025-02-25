import express, { Application, Request, Response } from 'express';
import bodyParser from 'body-parser';

const app: Application = express();

// Middleware
app.use(bodyParser.json());


// Test Route
app.get('/', (req: Request, res: Response) => {

  res.send('Server is running!');
});

export default app;