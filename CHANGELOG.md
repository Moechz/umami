# Changelog

All notable user-visible changes to the Umami TOS application package.

## 2.15.1-1 — 2026-11-14

### Added
- First release. Umami (`moechz/umami:postgresql-v2.15.1`, Docker Hub official image, unmodified)
  packaged as a TOS 7 Docker application, published on port 8152 and running
  as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/umamidocker/`.
