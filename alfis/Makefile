include $(TOPDIR)/rules.mk

PKG_NAME:=alfis
PKG_VERSION:=0.10.0
PKG_RELEASE:=2

PKG_SOURCE_URL:=https://github.com/Revertron/Alfis/releases/download/v$(PKG_VERSION)

ifeq ($(ARCH),aarch64)
  ALFIS_RELEASE_ARCH:=arm64
  PKG_HASH:=e750b6a0b2bfe8a09a9f5f0ea28418d719853a807740894c3d8c0978f3c09734
else ifeq ($(ARCH),arm)
  ALFIS_RELEASE_ARCH:=armhf
  PKG_HASH:=8df0d1eb2dbdefb73fc0267530316d83d2c13ee0378369405a70bc9d9d70481a
else ifeq ($(ARCH),x86_64)
  ALFIS_RELEASE_ARCH:=amd64
  PKG_HASH:=bc1206e740ffff6443b24ac62df7cb43a076bb378a643762200ac19576826b04
endif

PKG_SOURCE:=alfis-linux-$(ALFIS_RELEASE_ARCH)-v$(PKG_VERSION)-nogui
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=AGPL-3.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=HodlOnToYourButts

include $(INCLUDE_DIR)/package.mk

define Package/alfis
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Alternative Free Identity System
  URL:=https://github.com/Revertron/Alfis
  DEPENDS:=@(aarch64||arm||x86_64) +libc +ca-certificates
  USERID:=alfis:alfis
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/alfis
	chmod 0755 $(PKG_BUILD_DIR)/alfis
endef

define Build/Compile
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
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/alfis $(1)/usr/bin/
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/alfis.init $(1)/etc/init.d/alfis
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/alfis.config $(1)/etc/config/alfis
	
	$(INSTALL_DIR) -m 0750 $(1)/etc/alfis
	$(INSTALL_CONF) -m 0640 ./files/alfis.toml $(1)/etc/alfis/alfis.toml
	
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/alfis.keep $(1)/lib/upgrade/keep.d/alfis
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
	exit 0
}
endef

$(eval $(call BuildPackage,alfis))
