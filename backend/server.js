const app = require('./src/app');
const { admin } = require('./src/config/firebase');

const PORT = process.env.PORT || 5000;

const server = app.listen(PORT, () => {
  console.log(`
    🚀 Server is running!
    📡 Port: ${PORT}
    Environment: ${process.env.NODE_ENV}
    Health Check: http://localhost:${PORT}/health
  `);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err, promise) => {
  console.log(`Error: ${err.message}`);
  // Close server & exit process
  server.close(() => process.exit(1));
});
