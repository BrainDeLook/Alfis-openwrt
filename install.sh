#!/bin/sh

set -eu

REPOSITORY="BrainDeLook/Alfis-openwrt"
RELEASE_TAG="${ALFIS_RELEASE_TAG:-alfis-0.10.0-openwrt-25.12.5-r4}"
BASE_URL="https://github.com/${REPOSITORY}/releases/download/${RELEASE_TAG}"
TMP_DIR=""

log() {
	printf '%s\n' "[alfis-installer] $*"
}

fail() {
	printf '%s\n' "[alfis-installer] ERROR: $*" >&2
	exit 1
}

cleanup() {
	if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
		rm -rf "$TMP_DIR"
	fi
}

download() {
	url="$1"
	destination="$2"

	if command -v uclient-fetch >/dev/null 2>&1; then
		uclient-fetch -O "$destination" "$url"
	elif command -v wget >/dev/null 2>&1; then
		wget -O "$destination" "$url"
	elif command -v curl >/dev/null 2>&1; then
		curl -fL -o "$destination" "$url"
	else
		fail "uclient-fetch, wget, or curl is required"
	fi
}

[ "$(id -u)" -eq 0 ] || fail "run this installer as root"
command -v apk >/dev/null 2>&1 || fail "this installer requires OpenWrt with apk"

ARCH="$(apk --print-arch 2>/dev/null | sed -n '1p')"
[ -n "$ARCH" ] || ARCH="$(uname -m)"

case "$ARCH" in
	aarch64*|arm64)
		BUNDLE_ARCH="aarch64_generic"
		;;
	arm_cortex-a7_neon-vfpv4|armv7*)
		BUNDLE_ARCH="arm_cortex-a7_neon-vfpv4"
		;;
	arm_arm1176jzf-s_vfp|armv6*)
		BUNDLE_ARCH="arm_arm1176jzf-s_vfp"
		;;
	i386_pentium4|i386|i486|i586|i686)
		BUNDLE_ARCH="i386_pentium4"
		;;
	mipsel_24kc|mipsel*)
		BUNDLE_ARCH="mipsel_24kc"
		;;
	mips_24kc|mips)
		BUNDLE_ARCH="mips_24kc"
		;;
	x86_64|amd64)
		BUNDLE_ARCH="x86_64"
		;;
	*)
		fail "unsupported package architecture: $ARCH"
		;;
esac

BUNDLE="alfis-openwrt-25.12.5-${BUNDLE_ARCH}.zip"
TMP_DIR="$(mktemp -d /tmp/alfis-install.XXXXXX)" || fail "cannot create temporary directory"
trap cleanup EXIT
trap 'exit 1' INT TERM

log "detected architecture: $ARCH"
log "downloading $BUNDLE"
download "$BASE_URL/$BUNDLE" "$TMP_DIR/$BUNDLE"
download "$BASE_URL/SHA256SUMS.txt" "$TMP_DIR/SHA256SUMS.txt"

EXPECTED_SHA256="$(awk -v bundle="$BUNDLE" '$2 == bundle { print $1; exit }' "$TMP_DIR/SHA256SUMS.txt")"
[ -n "$EXPECTED_SHA256" ] || fail "checksum for $BUNDLE is missing"
ACTUAL_SHA256="$(sha256sum "$TMP_DIR/$BUNDLE" | awk '{ print $1 }')"
[ "$ACTUAL_SHA256" = "$EXPECTED_SHA256" ] || fail "SHA-256 verification failed for $BUNDLE"
log "SHA-256 verification passed"

if ! command -v unzip >/dev/null 2>&1; then
	log "installing unzip"
	apk add unzip
fi

unzip -q "$TMP_DIR/$BUNDLE" -d "$TMP_DIR/packages"
ALFIS_APK="$(find "$TMP_DIR/packages" -maxdepth 1 -name 'alfis-*.apk' -print | sed -n '1p')"
LUCI_APK="$(find "$TMP_DIR/packages" -maxdepth 1 -name 'luci-app-alfis-*.apk' -print | sed -n '1p')"
[ -f "$ALFIS_APK" ] || fail "Alfis APK is missing from the downloaded bundle"
[ -f "$LUCI_APK" ] || fail "LuCI APK is missing from the downloaded bundle"

log "installing Alfis and LuCI"
apk add --allow-untrusted "$ALFIS_APK" "$LUCI_APK"

uci -q get alfis.config >/dev/null 2>&1 || uci set alfis.config=alfis
uci -q get alfis.config.data_dir >/dev/null 2>&1 || uci set alfis.config.data_dir='/opt/alfis'
uci set alfis.config.enabled='1'
uci commit alfis

/etc/init.d/alfis enable
/etc/init.d/alfis restart
[ ! -x /etc/init.d/rpcd ] || /etc/init.d/rpcd restart
[ ! -x /etc/init.d/uhttpd ] || /etc/init.d/uhttpd restart

log "installation completed"
log "LuCI: Services -> Alfis DNS"
log "persistent data directory: $(uci -q get alfis.config.data_dir || printf '/opt/alfis')"
log "service status:"
/etc/init.d/alfis status || true
