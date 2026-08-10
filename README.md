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

For x86, x86_64, aarch64, ARMv6, and ARMv7, the package uses the official
Alfis 0.10.0 headless musl binaries and verifies their upstream SHA-256
checksums before packaging. MIPS and MIPSel are cross-compiled from the pinned
v0.10.0 source commit without GUI or DoH support.

The primary AArch64 artifact is built with the OpenWrt `armsr/armv8` SDK and
has the generic `aarch64_generic` package architecture, rather than being tied
to a specific router SoC target.

### luci-app-alfis
Web interface for managing and monitoring the Alfis DNS service through LuCI.

**Features:**
- Enable/disable Alfis service
- Configure the persistent database directory
- Configure P2P, DNS, forwarders, and bootstrap nodes
- Configure DNS cache, DNS 0x20 protection, and mining
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

### Automatic installer

Run as `root` on OpenWrt 25.12.5. The installer detects the package
architecture, downloads both Alfis and LuCI, installs them, and starts the
service:

```sh
wget -O /tmp/install-alfis.sh https://raw.githubusercontent.com/BrainDeLook/Alfis-openwrt/master/install.sh
sh /tmp/install-alfis.sh
```

The package configures split DNS automatically: dnsmasq forwards all ten Alfis
blockchain zones to `127.0.0.1#5353`, while ordinary Internet domains continue
to use the router's existing upstream DNS servers. Reinstalling or upgrading
the package does not create duplicate forwarding rules.

The release tag can be overridden when testing another package revision:

```sh
ALFIS_RELEASE_TAG='alfis-0.10.0-openwrt-25.12.5-r4' sh /tmp/install-alfis.sh
```

After installation, open **Services -> Alfis DNS** in LuCI.

### Manual installation

1. Download the archive matching `apk --print-arch` from the GitHub release.
2. Extract the archive on the router.
3. Install both packages: `apk add --allow-untrusted ./alfis-*.apk ./luci-app-alfis-*.apk`.
4. Enable and start the service: `/etc/init.d/alfis enable && /etc/init.d/alfis restart`.

The blockchain database and key files are stored in `/opt/alfis` by default.
This directory survives service and router restarts and is listed in
`/lib/upgrade/keep.d/alfis` for sysupgrade backups. The location can be changed
with the `data_dir` UCI/LuCI option to persistent storage under `/opt`, `/mnt`,
`/srv`, or `/var/lib`.

## Configuration

### UCI Configuration (`/etc/config/alfis`):
- `enabled`: Enable/disable service (0/1)
- `data_dir`: Persistent database and key directory (default: `/opt/alfis`)
- `net_listen`: P2P listen address (default: `[::]:4244`)
- `net_peers`: Initial P2P peers
- `dns_listen`: DNS listen address (default: `127.0.0.1:5353`)
- `dns_threads`: DNS worker threads
- `dns_cache_memory_limit_mb`: In-memory DNS cache limit
- `dns_enable_0x20`: DNS query-name case randomization
- `dns_forwarders`: Upstream DNS-over-HTTPS resolvers
- `dns_bootstraps`: Bootstrap DNS servers
- `mining_threads`: Mining worker threads (`0` uses the available CPU cores)

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
