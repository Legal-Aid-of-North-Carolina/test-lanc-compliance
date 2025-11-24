# 📚 LANC Standards Reference Implementation

**🎯 PURPOSE: This repository serves as the official reference implementation of LANC Repository Standards.**

**⚠️ This is NOT a production service** - it's maintained as a living example of perfect LANC standards compliance.

## Standards Compliance

This repository follows [LANC Repository Standards](https://github.com/Legal-Aid-of-North-Carolina/lanc-standards).
For development guidelines, templates, and best practices, see the [LANC Standards Documentation](https://github.com/Legal-Aid-of-North-Carolina/lanc-standards/blob/main/REPOSITORY_STANDARDS.md).

**Use this repository as a reference when:**

- Creating new LANC repositories
- Updating existing repositories for compliance
- Training developers on LANC standards
- Testing GitHub Copilot prompt templates

## 🏗️ Reference Deployments (Currently Stopped)

_Note: Azure resources are stopped to prevent any costs but maintained for reference_

- **Development**: https://test-lanc-compliance-development.azurewebsites.net/ (Stopped)
- **Staging**: https://test-lanc-compliance-staging.azurewebsites.net/ (Stopped)
- **Production**: https://test-lanc-compliance.azurewebsites.net/ (Stopped)## 💡 Reference Implementation Features

This repository demonstrates **perfect LANC compliance** with:

✅ **All Required Health Endpoints**

- `GET /health` - Comprehensive health check
- `GET /health/readiness` - Container readiness probe
- `GET /health/liveness` - Container liveness probe
- `GET /api/status` - Service-specific status

✅ **Complete Three-Tier Architecture**

- Development → Staging → Production deployment pipeline
- GitHub Actions workflows for each environment
- Azure App Service configuration

✅ **Security & Best Practices**

- Helmet.js security headers
- CORS configuration
- Structured error handling
- Winston logging
- Docker multi-stage builds

✅ **Latest Dependency Standards**

- Node.js 20 LTS runtime
- Latest stable dependency versions
- Proper semantic versioning

## 🚀 Quick Start (For Reference Only)

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

| Variable   | Description                                  | Default       |
| ---------- | -------------------------------------------- | ------------- |
| `NODE_ENV` | Environment (development/staging/production) | `development` |
| `PORT`     | Server port                                  | `3000`        |

## Deployment

This service uses three-tier deployment:

- **Development** → `development` branch → Auto-deploy to Azure development environment
- **Staging** → `staging` branch → Auto-deploy to Azure staging environment
- **Production** → `main` branch → Auto-deploy to Azure production environment

## License

MIT
