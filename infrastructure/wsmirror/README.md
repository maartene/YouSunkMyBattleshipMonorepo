# WebSocket Echo Server (wsmirror)

Build the image:

```bash
docker build -t wsmirror .
```

Run the container (maps host 8080 to container 8080):

```bash
docker run --rm -p 8080:8080 wsmirror
```

Test with `websocat` or `wscat`:

```bash
# using websocat
websocat ws://localhost:8080

# using wscat
wscat -c ws://localhost:8080
```

Any message you send will be mirrored back by the server.
