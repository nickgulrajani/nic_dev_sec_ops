const express = require('express');
const mongoose = require('mongoose');
const appInsights = require('applicationinsights');
const health = require('./health');

const app = express();
const port = process.env.PORT || 3000;

if (process.env.APPLICATIONINSIGHTS_CONNECTION_STRING) {
  appInsights.setup().start();
}

mongoose.connect(process.env.MONGODB_URI);

app.use('/health', health);

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
