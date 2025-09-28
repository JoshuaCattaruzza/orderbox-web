import WebSocket, { WebSocketServer } from 'ws';

const PORT = 8080;

// Create a WebSocket server
const wss = new WebSocketServer({ port: PORT }, () => {
  console.log(`WebSocket server listening on port ${PORT}`);
});

// Handle connections
wss.on('connection', (ws) => {
  console.log('New client connected');

  // Send a welcome message
  ws.send(JSON.stringify({ message: 'Hello from WebSocket server!' }));

  // Log messages from clients
  ws.on('message', (msg) => {
    console.log('Received from client:', msg.toString());
    ws.send(`Echo: ${msg.toString()}`);
  });

  ws.on('close', () => {
    console.log('Client disconnected');
  });
});
