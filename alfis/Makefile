include $(TOPDIR)/rules.mk

PKG_NAME:=alfis
PKG_VERSION:=0.10.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Revertron/Alfis.git
PKG_SOURCE_VERSION:=61212e4160ca16ae94564b241b77ab7de8726568
PKG_MIRROR_HASH:=skip
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=AGPL-3.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=HodlOnToYourButts

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

RUST_PKG_FEATURES:=doh

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/alfis
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Alternative Free Identity System
  URL:=https://github.com/Revertron/Alfis
  DEPENDS:=$(RUST_ARCH_DEPENDS) +libc +ca-certificates
  USERID:=alfis:alfis
endef

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
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/alfis $(1)/usr/bin/
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/alfis.init $(1)/etc/init.d/alfis
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/alfis.config $(1)/etc/config/alfis
	
	$(INSTALL_DIR) -m 0750 $(1)/etc/alfis
	$(INSTALL_CONF) -m 0640 ./files/alfis.toml $(1)/etc/alfis/alfis.toml
	
	$(INSTALL_DIR) -m 0750 $(1)/tmp/lib/alfis
endef

define Package/alfis/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	# Set ownership and permissions for alfis directories
	[ -d /etc/alfis ] && chown alfis:alfis /etc/alfis && chmod 750 /etc/alfis
	[ -f /etc/alfis/alfis.toml ] && chown alfis:alfis /etc/alfis/alfis.toml && chmod 640 /etc/alfis/alfis.toml
	[ -d /tmp/lib/alfis ] && chown alfis:alfis /tmp/lib/alfis && chmod 750 /tmp/lib/alfis
	# Create zones directory if it doesn't exist
	[ -d /var/lib/alfis ] || mkdir -p /var/lib/alfis
	chown alfis:alfis /var/lib/alfis && chmod 750 /var/lib/alfis
	exit 0
}
endef

$(eval $(call RustBinPackage,alfis))
$(eval $(call BuildPackage,alfis))
