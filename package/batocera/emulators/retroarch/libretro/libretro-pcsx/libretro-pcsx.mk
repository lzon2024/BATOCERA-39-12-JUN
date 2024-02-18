################################################################################
#
# libretro-pcsx
#
################################################################################
# Version: Commits on Oct 13, 2023
LIBRETRO_PCSX_VERSION = b51e7884dc9a1d04f852cb3a12d2033a4d930024
LIBRETRO_PCSX_SITE = $(call github,libretro,pcsx_rearmed,$(LIBRETRO_PCSX_VERSION))
LIBRETRO_PCSX_LICENSE = GPLv2

LIBRETRO_PCSX_EXTRA_OPTIONS =
LIBRETRO_PCSX_PLATFORM = $(LIBRETRO_PLATFORM)

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_S922X),y)
LIBRETRO_PCSX_PLATFORM = CortexA73_G12B
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2835),y)
LIBRETRO_PCSX_PLATFORM = rpi1
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2836),y)
LIBRETRO_PCSX_PLATFORM = rpi2
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2837),y)
LIBRETRO_PCSX_PLATFORM = rpi3_64
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2711),y)
LIBRETRO_PCSX_PLATFORM = rpi4_64
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2712),y)
LIBRETRO_PCSX_PLATFORM = rpi5_64
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RK3326),y)
LIBRETRO_PCSX_PLATFORM = rk3326
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_LIBRETECH_H5),y)
LIBRETRO_PCSX_PLATFORM = h5
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_S812),y)
LIBRETRO_PCSX_PLATFORM = armv cortexa9 neon hardfloat
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_H3),y)
LIBRETRO_PCSX_PLATFORM = rpi2
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RK3128),y)
LIBRETRO_PCSX_PLATFORM = rpi2
else ifeq ($(BR2_aarch64),y)
LIBRETRO_PCSX_PLATFORM = unix
LIBRETRO_PCSX_EXTRA_OPTIONS = DYNAREC=ari64
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_X86_64_ANY),y)
LIBRETRO_PCSX_PLATFORM = unix
LIBRETRO_PCSX_EXTRA_OPTIONS = HAVE_LIGHTREC=1 LIGHTREC_CUSTOM_MAP=0
endif

define LIBRETRO_PCSX_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" -C $(@D) -f Makefile.libretro platform="$(LIBRETRO_PCSX_PLATFORM)" $(LIBRETRO_PCSX_EXTRA_OPTIONS) \
        GIT_VERSION="-$(shell echo $(LIBRETRO_PCSX_VERSION) | cut -c 1-7)"
endef

define LIBRETRO_PCSX_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/pcsx_rearmed_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/pcsx_rearmed_libretro.so
	#Gun1 evmapy
	cp -f $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/libretro/libretro-pcsx_rearmed/psx.libretro.keys $(TARGET_DIR)/usr/share/evmapy/
endef

$(eval $(generic-package))
