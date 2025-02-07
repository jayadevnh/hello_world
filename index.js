const express = require('express');
const serverless = require('serverless-http');
const app = express();

app.get('*', (req, res) => {
  res.send('Hello, World!');
});

// Export the Lambda handler
module.exports.lambdaHandler = serverless(app);
