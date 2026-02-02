const { exit } = require('process');
const WebSocket = require('ws');

const port = process.env.PORT || 8080;
const wss = new WebSocket.Server({ port: port });

wss.on('connection', function connection(ws) {
    ws.send('Welcome to the WebSocket echo server!');
  ws.on('message', function message(data) {
    // Mirror back exactly what was received
    console.log(`Received: ${data}`);
    ws.send(`Mirroring: ${data}`);
  });
});

console.log(`WebSocket echo server listening on port ${port}`);
