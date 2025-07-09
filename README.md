
# Starpeace Prototype System

This prototype demonstrates a minimal event-driven architecture using Go microservices, Kafka, and MongoDB.

---

## 🚀 Included Services

| Service       | Description                                  | Port |
|---------------|----------------------------------------------|------|
| **Traefik**   | Reverse proxy and router                     | 80, 8080 |
| **Zookeeper** | Coordination service for Kafka               | 2181 |
| **Kafka**     | Message broker for event-based communication | 9092 |
| **kafka-init**| Initializes Kafka topics                      | N/A |
| **Kafdrop**   | Web UI for Kafka (via Traefik)               | 80 |

---

## 🧱 Directory Structure

```
prototype/                    # This repo (contains the compose file)
../kafka-base-environment-image/   # Kafka docker setup
../golang-kafka-hybrid-auth/       # Auth service
```

---

## 🛠 Prerequisites

- Docker + Docker Compose installed
- All referenced repos cloned next to this one
- (Optional) `.env` file for secret overrides

---

## 🔐 Certificate Management

Run `./generate-certs.sh` before starting the stack to create a local
certificate authority and TLS certificates for the client and auth
services. The script places the generated files in `certs/` and copies
them into each service repository so the containers can mount them.

---

## ▶️ Running the System

From inside the `prototype/` folder:

```bash
docker-compose up --build
```

This will:
- Start Traefik, Zookeeper, a Kafka cluster with three brokers, a helper container to create topics, the relay and client services, and the Kafdrop UI
- Route the Kafdrop UI to `http://kafdrop.localhost` and the client to `http://client.localhost`
- Expose the Traefik dashboard at `http://localhost:8080/dashboard/`
- (Ensure your hosts file maps `kafdrop.localhost` and `client.localhost` to `127.0.0.1`)

---

## 🔌 Environment Variables

### Auth Service
These are passed automatically in the Compose file:

```env
MONGO_URI=mongodb://mongo:27017
KAFKA_BROKER=kafka:9092
```

If you need to override or expand config, edit the `docker-compose.yml`.

---

## 🔄 Inter-Service Flow

1. Kafka starts and waits for incoming topics/messages
2. MongoDB stores auth/user state
3. Auth service consumes from Kafka and interacts with MongoDB

---

## 📦 Extending the Prototype

You can add additional services from the Starpeace repo set:

- `gk-kafka-relay`
- `gk-kafka-client`
- `gk-message-transport`
- `gk-events`

Just clone the corresponding repo and add a new `service:` block to the Compose file.

Let me know if you’d like help doing that.

---

## 🧹 Teardown

To stop and clean up everything:

```bash
docker-compose down -v
```

This removes containers and any created volumes.

---

## 📄 License

MIT – see [LICENSE](LICENSE.md) for details. See individual repos for more details.
