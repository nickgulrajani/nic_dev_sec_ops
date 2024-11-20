const express = require('express');
const app = express();
const port = process.env.PORT || 4000;

// Middleware for JSON parsing
app.use(express.json());

// Basic logging middleware
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        port: port,
        environment: process.env.NODE_ENV || 'development',
        version: '1.0.0'
    });
});

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to the DevOps Demo API',
        documentation: '/api-docs',
        healthCheck: '/health',
        timestamp: new Date().toISOString()
    });
});

// System information endpoint
app.get('/system', (req, res) => {
    res.json({
        nodeVersion: process.version,
        platform: process.platform,
        memoryUsage: process.memoryUsage(),
        uptime: process.uptime(),
        env: process.env.NODE_ENV || 'development'
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(`Error: ${err.message}`);
    res.status(500).json({
        error: 'Internal Server Error',
        message: err.message,
        timestamp: new Date().toISOString()
    });
});

// Start server
app.listen(port, () => {
    console.log(`Server started at ${new Date().toISOString()}`);
    console.log(`Server is running on port ${port}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received. Performing graceful shutdown...');
    process.exit(0);
});