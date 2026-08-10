include $(TOPDIR)/rules.mk

PKG_NAME:=alfis
PKG_VERSION:=0.10.0
PKG_RELEASE:=4

ifeq ($(ARCH),aarch64)
  ALFIS_RELEASE_ARCH:=arm64
  PKG_HASH:=e750b6a0b2bfe8a09a9f5f0ea28418d719853a807740894c3d8c0978f3c09734
else ifeq ($(ARCH),arm)
  ifeq ($(CONFIG_arm_v7),y)
    ALFIS_RELEASE_ARCH:=armhf
    PKG_HASH:=8df0d1eb2dbdefb73fc0267530316d83d2c13ee0378369405a70bc9d9d70481a
  else
    ALFIS_RELEASE_ARCH:=armel
    PKG_HASH:=2c5769a53d35be3fbec290d1d3f5f235939320704d3b700e23fc32282e7c835a
  endif
else ifeq ($(ARCH),i386)
  ALFIS_RELEASE_ARCH:=i686
  PKG_HASH:=a3fdef32212491a55620d4dd388d9adc8077f70bbe684b64b98e7009a7bc0381
else ifeq ($(ARCH),x86_64)
  ALFIS_RELEASE_ARCH:=amd64
  PKG_HASH:=bc1206e740ffff6443b24ac62df7cb43a076bb378a643762200ac19576826b04
endif

ifneq ($(ALFIS_RELEASE_ARCH),)
  ALFIS_PREBUILT:=1
  PKG_SOURCE:=alfis-linux-$(ALFIS_RELEASE_ARCH)-v$(PKG_VERSION)-nogui
  PKG_SOURCE_URL:=https://github.com/Revertron/Alfis/releases/download/v$(PKG_VERSION)
else
  PKG_SOURCE_PROTO:=git
  PKG_SOURCE_URL:=https://github.com/Revertron/Alfis.git
  PKG_SOURCE_VERSION:=61212e4160ca16ae94564b241b77ab7de8726568
  PKG_MIRROR_HASH:=skip
  PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
  PKG_BUILD_DEPENDS:=rust/host
  PKG_BUILD_PARALLEL:=1
  RUST_PKG_LOCKED:=1
endif

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=AGPL-3.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=HodlOnToYourButts

include $(INCLUDE_DIR)/package.mk

ifneq ($(ALFIS_PREBUILT),1)
  include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk
  CARGO_PKG_ARGS+=--no-default-features
endif

define Package/alfis
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Alternative Free Identity System
  URL:=https://github.com/Revertron/Alfis
  DEPENDS:=@(aarch64||arm||i386||mips||mipsel||x86_64) +libc +ca-certificates
  USERID:=alfis:alfis
endef

ifeq ($(ALFIS_PREBUILT),1)
  define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/alfis
	chmod 0755 $(PKG_BUILD_DIR)/alfis
  endef

  define Build/Compile
  endef

  ALFIS_BINARY:=$(PKG_BUILD_DIR)/alfis
else
  ALFIS_BINARY:=$(PKG_INSTALL_DIR)/bin/alfis
endif

define Package/alfis/description
  Alfis is an alternative free identity system - a minimal blockchain 
  for managing domain names without cryptocurrency. It provides a 
  decentralized DNS server with blockchain-based domain resolution
  supporting domains like .anon, .btn, .conf and others.
endef

define Package/alfis/conffiles
/etc/config/alfis
/etc/alfis/alfis.toml
endef

define Package/alfis/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(ALFIS_BINARY) $(1)/usr/bin/
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/alfis.init $(1)/etc/init.d/alfis
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/alfis.config $(1)/etc/config/alfis
	
	$(INSTALL_DIR) -m 0750 $(1)/etc/alfis
	$(INSTALL_CONF) -m 0640 ./files/alfis.toml $(1)/etc/alfis/alfis.toml
	
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/alfis.keep $(1)/lib/upgrade/keep.d/alfis

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/50-alfis-dnsmasq $(1)/etc/uci-defaults/50-alfis-dnsmasq
endef

define Package/alfis/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	# Set ownership and permissions for alfis directories
	[ -d /etc/alfis ] && chown alfis:alfis /etc/alfis && chmod 750 /etc/alfis
	[ -f /etc/alfis/alfis.toml ] && chown alfis:alfis /etc/alfis/alfis.toml && chmod 640 /etc/alfis/alfis.toml
	# The blockchain lives outside /tmp so it survives service and router restarts.
	[ -d /opt/alfis ] || mkdir -p /opt/alfis
	chown alfis:alfis /opt/alfis && chmod 750 /opt/alfis
	# Configure split DNS immediately during a live install. ImageBuilder installs
	# keep the uci-defaults script so the same setup runs on first boot.
	if [ -x /etc/uci-defaults/50-alfis-dnsmasq ]; then
		/etc/uci-defaults/50-alfis-dnsmasq && rm -f /etc/uci-defaults/50-alfis-dnsmasq
	fi
}
exit 0
endef

define Package/alfis/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	changed=0
	for zone in anon btn conf index merch mirror mob screen srv ygg; do
		rule="/$$zone/127.0.0.1#5353"
		if uci -q del_list "dhcp.@dnsmasq[0].server=$$rule"; then
			changed=1
		fi
	done
	if [ "$$changed" -eq 1 ]; then
		uci commit dhcp
		[ ! -x /etc/init.d/dnsmasq ] || /etc/init.d/dnsmasq reload || true
	fi
}
exit 0
endef

$(eval $(call BuildPackage,alfis))
