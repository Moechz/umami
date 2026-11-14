# umami-for-tos

> TerraMaster TOS 7 App Center — **Docker application** package for
> [Umami](https://github.com/umami-software/umami).

## What this is

A four-file TOS Docker application archive (`umamidocker.tar.gz`) that installs
Umami on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`, id `umamidocker`)
- `umamidocker.lang` — 23-language superset (TOS requires 14)
- `umamidocker.svg` — application icon (533 bytes, 3 SVG elements)
- `docker-compose.yml` — one service, image `moechz/umami:postgresql-v2.15.1`

## How it works

| | |
|---|---|
| Container image | `moechz/umami:postgresql-v2.15.1` (Docker Hub, used unmodified) |
| Open | `http://<NAS-IP>:8152/` (container port 3000) |
| Runs as | non-root, `user: "1000:1000"` |
| Persistent data | `/data` → `/Volume1/DockerAppData/umamidocker/data`, `/var/lib/postgresql/data` → `/Volume1/DockerAppData/umamidocker/db` |
| Logs | `docker logs umamidocker` (stdout/stderr) |



## Design highlights

- **Non-root.** `user: "1000:1000"`; verified on real hardware (the container reports uid 1000).
- **Entrypoint wrapper**: the upstream image is built to run as root and keeps state in root-owned paths, so the compose file replaces the entrypoint with `src/entrypoint.sh`, which makes the service run as an unprivileged user. See that file for the details.
- **Fixed image tag, never `:latest`**, Docker Hub only, no `privileged`, no `network_mode: host`, and no Docker socket, no `cap_add`.
- **Health check** probing the service on container port 3000.
- **Deterministic build**: GNU tar with uid/gid 0 and zeroed timestamps, gzip without a timestamp, plus the review-standards self-check above.

## Runtime file manifest

Everything the application writes on the NAS lives inside its own data
directory; the container-internal `/tmp` is discarded with the container. The
table lists what is created and how it behaves. Nothing else is written.

| Path | Purpose | Created when | Growth bound | Lifecycle |
|---|---|---|---|---|
| `/Volume1/DockerAppData/umamidocker/data` | Umami application data (everything the container writes outside /tmp) | on first start / on demand | bounded by your own data | persistent; kept on uninstall unless you ask to delete it |
| `/Volume1/DockerAppData/umamidocker/db` | Umami application data (everything the container writes outside /tmp) | on first start / on demand | bounded by your own data | persistent; kept on uninstall unless you ask to delete it |

## Build

```bash
scripts/build.sh                  # -> out/umamidocker.tar.gz + .sha256
scripts/build.sh 2.15.1-2   # packaging iteration bump
scripts/build.sh 2.15.1-1 aarch64
```

The build stages the four files, substitutes the version/platform placeholders,
embeds `src/entrypoint.sh` into the compose file (escaping every `$` as `$$`), removes CRLF/BOM/AppleDouble, then runs
`tools/verify.py`, a review-standards self-check (archive layout, JSON validity,
required fields, 14+ language coverage, version consistency, Docker-Hub-only
images, fixed tag, reserved/recommended host ports, non-root user, per-service
healthcheck/TZ/restart, data path below the application data root, never the
`/Volume*` wildcard, comment-free sequence blocks, `x-app-meta` position, no
literal secrets and the SVG size/element limits).

## Local verification

```bash
./TOSAppSelfTestingTool -c out/umamidocker.tar.gz   # official spec check
bash test/install-and-verify.sh                  # on-device E2E (needs root)
```

> Docker applications cannot be side-loaded through the App Center's manual
> install page (it accepts `.deb` only); the official self-testing tool's `-i`
> mode or `docker compose` are the only ways to install one for testing.

## Store submission checklist

1. Public GitHub repo (code + README only).
2. Release **tag `v2.15.1-1`**, assets `umamidocker.tar.gz` +
   `umamidocker.tar.gz.sha256` (Docker asset naming: `<app_id>.tar.gz`, **no
   platform suffix**).
3. Developer platform → Add Application: ID `umamidocker`, package type Docker,
   repository URL, architecture `x86_64`.
4. Version Management → Add Version `2.15.1-1` → automated validation → review.

## License / branding

Umami is distributed by its upstream authors under **MIT**. The container image is the official image from Docker Hub (`moechz/umami:postgresql-v2.15.1`) and is used unmodified; no upstream source code is redistributed here. This packaging is an independent community submission by Moechz and is not affiliated with the upstream project or TerraMaster.

## Limitations

- The application runs inside a container; data lives in the application data directory (`/Volume1/DockerAppData/umamidocker/`) as described above.

---

Packaged for TOS 7 by Moechz. Upstream image used unmodified from Docker Hub.
