################################################################################
#
# libretro-beetle-pcfx
#
################################################################################
# Version.: Commits on Mar 8, 2022
LIBRETRO_BEETLE_PCFX_VERSION = 00abc26cafb15cc33dcd73f4bd6b93cbaab6e1ea
LIBRETRO_BEETLE_PCFX_SITE = $(call github,libretro,beetle-pcfx-libretro,$(LIBRETRO_BEETLE_PCFX_VERSION))
LIBRETRO_BEETLE_PCFX_LICENSE = GPLv2

LIBRETRO_BEETLE_PCFX_PLATFORM = $(LIBRETRO_PLATFORM)

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_S922X),y)
LIBRETRO_BEETLE_PCFX_PLATFORM = CortexA73_G12B

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RK3399)$(BR2_PACKAGE_BATOCERA_TARGET_RG552)$(BR2_PACKAGE_BATOCERA_TARGET_ORANGE_PI4_LTS),y)
LIBRETRO_BEETLE_PCFX_PLATFORM = rpi4

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RPI4),y)
LIBRETRO_BEETLE_PCFX_PLATFORM = rpi4

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_S905)$(BR2_PACKAGE_BATOCERA_TARGET_S905GEN2),y)
LIBRETRO_BEETLE_PCFX_PLATFORM = S905

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_ORANGEPI_ZERO2),y)
LIBRETRO_BEETLE_PCFX_PLATFORM = S905

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_S905GEN3),y)
LIBRETRO_BEETLE_PCFX_PLATFORM = SM1

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_S812),y)
LIBRETRO_BEETLE_PCFX_PLATFORM = armv

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_ODIN),y)
LIBRETRO_BEETLE_PCFX_PLATFORM = odin
endif

define LIBRETRO_BEETLE_PCFX_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" -C $(@D) platform="$(LIBRETRO_BEETLE_PCFX_PLATFORM)" \
        GIT_VERSION="-$(shell echo $(LIBRETRO_BEETLE_PCFX_VERSION) | cut -c 1-7)"
endef

define LIBRETRO_BEETLE_PCFX_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/mednafen_pcfx_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/pcfx_libretro.so
endef

$(eval $(generic-package))
