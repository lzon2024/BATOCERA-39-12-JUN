################################################################################
#
# libretro-stella
#
################################################################################
# Version: Commits on Oct 26, 2023
LIBRETRO_STELLA_VERSION = 341c6d860cdb028f29caf8bb30e9acd3d8521ac1
LIBRETRO_STELLA_SITE = $(call github,stella-emu,stella,$(LIBRETRO_STELLA_VERSION))
LIBRETRO_STELLA_LICENSE = GPLv2

LIBRETRO_STELLA_PLATFORM = $(LIBRETRO_PLATFORM)

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2835),y)
LIBRETRO_STELLA_PLATFORM = rpi1
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2836),y)
LIBRETRO_STELLA_PLATFORM = rpi2
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2837),y)
LIBRETRO_STELLA_PLATFORM = rpi3_64
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2711),y)
LIBRETRO_STELLA_PLATFORM = rpi4
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2712),y)
LIBRETRO_STELLA_PLATFORM = rpi5
endif

define LIBRETRO_STELLA_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" -C \
	    $(@D)/src/os/libretro -f Makefile platform="$(LIBRETRO_STELLA_PLATFORM)" \
        GIT_VERSION="-$(shell echo $(LIBRETRO_STELLA_VERSION) | cut -c 1-7)"
endef

define LIBRETRO_STELLA_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/src/os/libretro/stella_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/stella_libretro.so
	#Gun1 evmapy	
	cp -f $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/libretro/libretro-stella/atari2600.libretro.keys $(TARGET_DIR)/usr/share/evmapy/
endef

$(eval $(generic-package))
