# Alfis OpenWRT Packages

This repository contains OpenWrt packages for Alfis - the Alternative Free Identity System.

The package tracks Alfis 0.10.0 and targets OpenWrt 25.12.5, which uses the
`apk` package format.

## Packages

### alfis
The main Alfis DNS server package that provides blockchain-based domain resolution for alternative TLDs like `.anon`, `.btn`, `.conf`, etc.

**Features:**
- DNS server with blockchain domain resolution
- P2P network synchronization
- Support for 10 alternative domain zones
- Configurable via UCI

**Dependencies:**
- ca-certificates

The package uses the official Alfis 0.10.0 headless musl binaries and verifies
their upstream SHA-256 checksums before packaging. Supported package
architectures are x86_64, aarch64, and ARMv7 hard-float.

### luci-app-alfis
Web interface for managing and monitoring the Alfis DNS service through LuCI.

**Features:**
- Enable/disable Alfis service
- Configure DNS and API ports
- Set logging levels
- Manage bootstrap nodes
- View service status

**Dependencies:**
- alfis package
- luci-base

## Building

### Build both packages:
```bash
make package/alfis/compile V=s
make package/luci-app-alfis/compile V=s
```

### Build only the base service:
```bash
make package/alfis/compile V=s
```

### Build only the web interface:
```bash
make package/luci-app-alfis/compile V=s
```

## Installation

1. Install the base package: `apk add --allow-untrusted ./alfis-*.apk`
2. Optionally install the web interface: `apk add --allow-untrusted ./luci-app-alfis-*.apk`
3. Configure via UCI or LuCI web interface
4. Enable and start the service: `/etc/init.d/alfis enable && /etc/init.d/alfis start`

The blockchain database and key files are stored in `/opt/alfis` by default.
This directory survives service and router restarts and is listed in
`/lib/upgrade/keep.d/alfis` for sysupgrade backups. The location can be changed
with the `data_dir` UCI/LuCI option to persistent storage under `/opt`, `/mnt`,
`/srv`, or `/var/lib`.

## Configuration

### UCI Configuration (`/etc/config/alfis`):
- `enabled`: Enable/disable service (0/1)
- `listen_dns`: DNS server port (default: 53)
- `listen_http`: HTTP API port (default: 8080)  
- `max_peers`: Maximum P2P peers (default: 32)
- `debug_level`: Log level (error/warn/info/debug/trace)
- `bootstrap_nodes`: List of initial nodes to connect to
- `zones`: Supported blockchain DNS zones

### File Locations:
- Configuration: `/etc/alfis/alfis.toml`
- Database and keys: `/opt/alfis/` (configurable)
- Logs: System journal/syslog

## Source

The packages download and build Alfis from: https://github.com/Revertron/Alfis

Official release binaries are downloaded from the Alfis v0.10.0 release and
packaged by the OpenWrt 25.12.5 SDK.

## Maintainer

HodlOnToYourButts
