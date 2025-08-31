# OpenVASD Container Setup

This repository includes Docker configurations to run Greenbone's OpenVASD scanner and feed synchronization as separate containers. It supports scanning on demand, shared feed volumes, and optional API key or mTLS security.

## Build and Run

### 1. Build Feed Sync Image

```bash
cd linux/feed
docker build -t greenbone-feed-sync .
````

### 2. Build OpenVASD Scanner Image

```bash
cd ../openvasd
docker build -t openvasd-scanner .
```

### 3. Start Containers with Docker Compose

```bash
cd feed
docker compose up -d

cd ../openvasd
docker compose up -d
```

## Configuration

### Enable API Key

Edit `openvasd/config.toml`:

```toml
[endpoints]
enable_get_scans = true
key = "your-api-key"
```

### Enable mTLS

```toml
[tls]
certs = "/certs/server.pem"
key = "/certs/server.rsa"
client_certs = "/certs/client"
```

Make sure to mount `/certs` into the container.

## Feed Volumes

Both containers must share these volumes:

* `/var/lib/openvas/plugins`
* `/var/lib/notus`

These paths should be mounted as volumes or bind mounts.

## Notes

* The OpenVASD service listens on `127.0.0.1:3001` by default.
* You can change the port in `config.toml`.
* Redis runs inside the container using a UNIX socket.

## License

See the [LICENSE](./LICENSE) file for details.
