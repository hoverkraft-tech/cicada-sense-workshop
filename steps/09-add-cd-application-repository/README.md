# Cicada Sense

Production-grade SaaS for real-time cicada ecosystem monitoring.

## Quick Start

```bash
make setup
make ci
```

Root commands use Docker Compose. Node.js package managers are scoped to application containers and are not required on the host.

## Local URLs

- Dashboard: `http://cicada-sense.localhost`
- Live data generator: `http://generator.cicada-sense.localhost`
- Traefik: `http://traefik.localhost:8080`

## Applications

- `application/monitoring-workspace/backend`: API, ingestion, domain use cases, realtime gateway.
- `application/monitoring-workspace/frontend`: monitoring workspace UI.
- `application/live-data-generator`: fixture live-data generator app with backend service and frontend console.

## Documentation

- [Specifications](docs/specifications.md)
- [Technical stories](docs/technical-stories.md)
- [Architecture](docs/technical/architecture/index.md)
- [Development](docs/technical/development/index.md)
