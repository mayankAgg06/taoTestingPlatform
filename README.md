# TAO Testing Platform - Sharda University

Docker-based deployment of TAO (Testing Assisté par Ordinateur) with custom Sharda University branding.

## Features

- Custom Sharda University logo integration
- MySQL 8.0 with proper authentication
- Nginx static file serving optimized
- Pre-configured admin credentials
- All TAO extensions installed

## Quick Start

cd example
docker-compose -f docker-compose-dev.yml up -d --build

text

Wait 3-5 minutes for installation to complete.

## Access

- URL: http://localhost
- Username: admin
- Password: admin123

## Requirements

- Docker
- Docker Compose

## Directory Structure

- `Dockerfile.custom` - Custom TAO image with logo
- `logo_white.png` - Sharda University logo
- `example/docker-compose-dev.yml` - Docker Compose configuration
- `example/nginx.conf` - Nginx web server configuration

## Installation Time

First-time build: ~10 minutes (downloads TAO base image)
Subsequent starts: ~3-5 minutes (TAO initialization)

## Troubleshooting

If containers fail to start:
docker-compose -f example/docker-compose-dev.yml down -v
docker-compose -f example/docker-compose-dev.yml up -d --build

text

## AWS Deployment

For deploying to AWS EC2, see the detailed guide: [AWS_DEPLOYMENT.md](AWS_DEPLOYMENT.md)

Quick AWS deployment:
1. Launch Ubuntu 22.04 t3.medium EC2 instance
2. Install Docker and Docker Compose
3. Clone this repository
4. Run `docker-compose -f example/docker-compose-dev.yml up -d --build`

Full instructions with SSL/HTTPS setup available in the deployment guide.
