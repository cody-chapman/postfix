# postfix

## Overview

This repository contains a containerized Postfix mail relay solution built on RedHat Enterprise Linux 9 UBI (Universal Base Image). It provides a lightweight, secure mail relay service designed for on-premises to off-premises mail forwarding with IP-based authentication.

## Purpose

This container is optimized for organizations that need to relay emails from internal on-premises systems to external mail services. It implements a minimal, focused configuration of Postfix with only the essential components needed for mail relay functionality.

## Key Features

- **RedHat Enterprise Linux 9 UBI Base**: Secure, minimal, and regularly updated container foundation
- **Postfix Mail Relay**: Lightweight mail transfer agent configured for basic relay operations
- **IP Authentication**: Authentication mechanism based on IP addresses (no complex credential management)
- **On-Prem to Off-Prem**: Designed to bridge mail services between internal and external infrastructure

## Repository Composition

- **Shell Scripts** (70.5%): Configuration and setup automation
- **Dockerfile** (29.5%): Container image definition

## Getting Started

### Prerequisites

- Git
- Docker or Podman
- Optional: Docker Compose or Podman Compose (for easier orchestration)

### Clone the Repository

```bash
git clone https://github.com/cody-chapman/postfix.git
cd postfix
```

### Running with Docker Compose

The easiest way to get started is using Docker Compose:

```bash
docker-compose up -d
```

Or if you prefer to build the image locally first:

```bash
docker-compose build
docker-compose up -d
```

### Running with Podman Compose

If you prefer Podman, the commands are similar:

```bash
podman-compose up -d
```

Or with a local build:

```bash
podman-compose build
podman-compose up -d
```

### Running with Docker

To run the container directly with Docker:

```bash
docker build -t postfix:latest .
docker run -d \
  --name postfix \
  --restart always \
  -p 25:25 \
  -p 465:465 \
  -p 587:587 \
  -e TZ=America/Chicago \
  -v $(pwd)/main.cf:/etc/postfix/main.cf \
  -v $(pwd)/allowed_hosts:/etc/postfix/allowed_hosts \
  postfix:latest
```

### Running with Podman

To run the container directly with Podman:

```bash
podman build -t postfix:latest .
podman run -d \
  --name postfix \
  --restart always \
  -p 25:25 \
  -p 465:465 \
  -p 587:587 \
  -e TZ=America/Chicago \
  -v $(pwd)/main.cf:/etc/postfix/main.cf \
  -v $(pwd)/allowed_hosts:/etc/postfix/allowed_hosts \
  postfix:latest
```

### Verify the Container is Running

```bash
docker ps
# or
podman ps
```

You should see the postfix container running with ports 25, 465, and 587 exposed.

## Configuration

The Postfix container uses two main configuration files:

- **main.cf**: Primary Postfix configuration file
- **allowed_hosts**: IP address whitelist for mail relay access

These files are mounted as volumes from the repository root. Edit them as needed and restart the container for changes to take effect.

### Stop and Remove the Container

```bash
# Docker
docker-compose down

# Podman
podman-compose down

# Or manually stop
docker stop postfix
docker rm postfix
```

## Requirements

- Docker or Podman
- Docker Compose or Podman Compose (optional, for simplified deployment)
- Adequate disk space for mail queue storage
- Network access to SMTP ports (25, 465, 587)

## License

[Add license information if applicable]
