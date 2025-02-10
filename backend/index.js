const express = require('express');
const serverless = require('serverless-http');
const app = express();

app.get('*', (req, res) => {
  res.send('Hello, World From ECR 1.0.2 !');
});

// Export the Lambda handler
module.exports.lambdaHandler = serverless(app);
