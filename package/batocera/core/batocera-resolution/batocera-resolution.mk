################################################################################
#
# batocera resolution
#
################################################################################

BATOCERA_RESOLUTION_VERSION = 1
BATOCERA_RESOLUTION_LICENSE = GPL
BATOCERA_RESOLUTION_DEPENDENCIES = pciutils
BATOCERA_RESOLUTION_SOURCE=

BATOCERA_RESOLUTION_PATH = $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/core/batocera-resolution/scripts

BATOCERA_SCRIPT_RESOLUTION_TYPE=basic
BATOCERA_SCRIPT_SCREENSHOT_TYPE=basic

ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
  BATOCERA_SCRIPT_RESOLUTION_TYPE=tvservice
  BATOCERA_SCRIPT_SCREENSHOT_TYPE=tvservice
endif

ifeq ($(BR2_PACKAGE_LIBDRM),y)
  BATOCERA_SCRIPT_RESOLUTION_TYPE=drm
  BATOCERA_SCRIPT_SCREENSHOT_TYPE=drm
endif

ifeq ($(BR2_PACKAGE_XSERVER_XORG_SERVER),y)
  BATOCERA_SCRIPT_RESOLUTION_TYPE=xorg
  BATOCERA_SCRIPT_SCREENSHOT_TYPE=xorg
  BATOCERA_SCRIPT_RECORDER_TYPE=xorg
endif

ifeq ($(BR2_PACKAGE_WAYLAND)$(BR2_PACKAGE_SWAY),yy)
  BATOCERA_SCRIPT_RESOLUTION_TYPE=wayland
  BATOCERA_SCRIPT_SCREENSHOT_TYPE=wayland
  BATOCERA_SCRIPT_RECORDER_TYPE=wayland
endif

# doesn't work on odroidgoa with mali g31_gbm
ifeq ($(BR2_PACKAGE_MALI_G31_GBM),y)
  BATOCERA_SCRIPT_RESOLUTION_TYPE=basic
endif

define BATOCERA_RESOLUTION_INSTALL_TARGET_CMDS
	install -m 0755 $(BATOCERA_RESOLUTION_PATH)/resolution/batocera-resolution.$(BATOCERA_SCRIPT_RESOLUTION_TYPE) $(TARGET_DIR)/usr/bin/batocera-resolution
	install -m 0755 $(BATOCERA_RESOLUTION_PATH)/screenshot/batocera-screenshot.$(BATOCERA_SCRIPT_SCREENSHOT_TYPE) $(TARGET_DIR)/usr/bin/batocera-screenshot
endef

define BATOCERA_RESOLUTION_INSTALL_RK3399
	install -m 0755 $(BATOCERA_RESOLUTION_PATH)/resolution/batocera-resolution-post-rk3399 $(TARGET_DIR)/usr/bin/batocera-resolution-post
endef

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RK3399),y)
  BATOCERA_RESOLUTION_POST_INSTALL_TARGET_HOOKS += BATOCERA_RESOLUTION_INSTALL_RK3399
endif

define BATOCERA_RESOLUTION_INSTALL_RK3128
        install -m 0755 $(BATOCERA_RESOLUTION_PATH)/resolution/batocera-resolution-post-rk3128 $(TARGET_DIR)/usr/bin/batocera-resolution-post
endef

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RK3128),y)
  BATOCERA_RESOLUTION_POST_INSTALL_TARGET_HOOKS += BATOCERA_RESOLUTION_INSTALL_RK3128
endif

define BATOCERA_RESOLUTION_INSTALL_XORG
	mkdir -p $(TARGET_DIR)/etc/X11/xorg.conf.d
	cp -prn $(BR2_EXTERNAL_BATOCERA_PATH)/board/batocera/x86/fsoverlay/etc/X11/xorg.conf.d/20-amdgpu.conf $(TARGET_DIR)/etc/X11/xorg.conf.d/20-amdgpu.conf
endef

ifeq ($(BR2_PACKAGE_XSERVER_XORG_SERVER),y)
  BATOCERA_RESOLUTION_POST_INSTALL_TARGET_HOOKS += BATOCERA_RESOLUTION_INSTALL_XORG
endif

define BATOCERA_RESOLUTION_INSTALL_RECORDER
    install -m 0755 $(BATOCERA_RESOLUTION_PATH)/recorder/batocera-record.$(BATOCERA_SCRIPT_RECORDER_TYPE) $(TARGET_DIR)/usr/bin/batocera-record
endef

ifeq ($(BR2_PACKAGE_XSERVER_XORG_SERVER)$(BR2_PACKAGE_SWAY),y)
    BATOCERA_RESOLUTION_POST_INSTALL_TARGET_HOOKS += BATOCERA_RESOLUTION_INSTALL_RECORDER
endif

$(eval $(generic-package))
