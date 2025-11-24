# Test LANC Compliance

Test repository to validate LANC standards compliance prompt template.

## Standards Compliance

This repository follows [LANC Repository Standards](https://github.com/Legal-Aid-of-North-Carolina/lanc-standards). 
For development guidelines, templates, and best practices, see the [LANC Standards Documentation](https://github.com/Legal-Aid-of-North-Carolina/lanc-standards/blob/main/REPOSITORY_STANDARDS.md).

## Live Deployments

- **Development**: https://test-lanc-compliance-development.azurewebsites.net/
- **Staging**: https://test-lanc-compliance-staging.azurewebsites.net/
- **Production**: https://test-lanc-compliance.azurewebsites.net/

## Quick Start

### Prerequisites

- Node.js 18+
- npm 9+

### Local Development

```bash
# Clone repository
git clone https://github.com/Legal-Aid-of-North-Carolina/test-lanc-compliance.git
cd test-lanc-compliance

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Start development server
npm run dev
```

### Testing

```bash
# Run tests
npm test

# Run linting
npm run lint
```

### Docker

```bash
# Build image
docker build -t test-lanc-compliance .

# Run container
docker run -p 3000:3000 test-lanc-compliance
```

## API Endpoints

### Health Endpoints (Required by LANC Standards)

- `GET /health` - Comprehensive health check with status, timestamp, version, environment
- `GET /health/readiness` - Readiness probe for Kubernetes/containers
- `GET /health/liveness` - Liveness probe for Kubernetes/containers
- `GET /api/status` - Service-specific status endpoint

### Service Endpoints

- `GET /api/hello` - Sample endpoint

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment (development/staging/production) | `development` |
| `PORT` | Server port | `3000` |

## Deployment

This service uses three-tier deployment:

- **Development** → `development` branch → Auto-deploy to Azure development environment
- **Staging** → `staging` branch → Auto-deploy to Azure staging environment  
- **Production** → `main` branch → Auto-deploy to Azure production environment

## License

MIT