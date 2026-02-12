const { exit } = require('node:process');
const WebSocket = require('ws');
const http = require('node:http');

const port = process.env.PORT || 8080;

// Create an HTTP server so we can serve an endpoint and upgrade to WebSocket on the same port
const server = http.createServer((req, res) => {
  if (req.method === 'GET' && req.url === '/hello') {
    const body = { name: 'a test', count: 42 };
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(body));
    return;
  }

  // For other routes return 404 minimal response
  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('Not found');
});

const wss = new WebSocket.Server({ server });

wss.on('connection', function connection(ws) {
  ws.send('Welcome to the WebSocket echo server!');
  ws.on('message', function message(data) {
    // Mirror back exactly what was received
    console.log(`Received: ${data}`);
    ws.send(`Mirroring: ${data}`);
  });
});

server.listen(port, () => {
  console.log(`Server (HTTP + WebSocket) listening on port ${port}`);
});
