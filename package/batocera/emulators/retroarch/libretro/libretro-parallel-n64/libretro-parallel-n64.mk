################################################################################
#
# PARALLEL_N64
#
################################################################################
# Version.: Commits on Jan 2, 2021
LIBRETRO_PARALLEL_N64_VERSION = 704b2cb4874fe01bc58467d1930c2a4fa5df777c
LIBRETRO_PARALLEL_N64_SITE = $(call github,libretro,parallel-n64,$(LIBRETRO_PARALLEL_N64_VERSION))
LIBRETRO_PARALLEL_N64_LICENSE = GPLv2

ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
	LIBRETRO_PARALLEL_N64_DEPENDENCIES += rpi-userland
endif

LIBRETRO_PARALLEL_N64_EXTRA_ARGS=
LIBRETRO_PARALLEL_N64_BOARD=

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RPI4),y)
        LIBRETRO_PARALLEL_N64_EXTRA_ARGS=ARCH=aarch64
	LIBRETRO_PARALLEL_N64_PLATFORM=rpi4_64

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RPI3),y)
	LIBRETRO_PARALLEL_N64_PLATFORM=rpi3-mesa

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_S812),y)
        LIBRETRO_PARALLEL_N64_PLATFORM=odroid

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RPI2),y)
	LIBRETRO_PARALLEL_N64_PLATFORM=rpi2

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_XU4),y)
	LIBRETRO_PARALLEL_N64_PLATFORM=odroid
	LIBRETRO_PARALLEL_N64_BOARD=ODROID-XU4

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_ODROIDC2),y)
        LIBRETRO_PARALLEL_N64_PLATFORM=h5

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_ORANGEPI_PC),y)
        LIBRETRO_PARALLEL_N64_PLATFORM=classic_armv7_a7

# unoptimized yet
else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_ODROIDC4),y)
	LIBRETRO_PARALLEL_N64_PLATFORM=h5

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_S905),y)
	LIBRETRO_PARALLEL_N64_EXTRA_ARGS=FORCE_GLES=1 ARCH=aarch64
	LIBRETRO_PARALLEL_N64_PLATFORM=unix

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_S912),y)
	LIBRETRO_PARALLEL_N64_EXTRA_ARGS=FORCE_GLES=1 ARCH=aarch64
	LIBRETRO_PARALLEL_N64_PLATFORM=unix

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_X86),y)
	LIBRETRO_PARALLEL_N64_EXTRA_ARGS=ARCH=x86
	LIBRETRO_PARALLEL_N64_PLATFORM=unix

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_X86_64),y)
	LIBRETRO_PARALLEL_N64_EXTRA_ARGS=ARCH=x86_64
	LIBRETRO_PARALLEL_N64_PLATFORM=unix

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_ROCKPRO64),y)
	LIBRETRO_PARALLEL_N64_PLATFORM=rockpro64

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_ROCK960),y)
	LIBRETRO_PARALLEL_N64_PLATFORM=rockpro64

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_LIBRETECH_H5),y)
        LIBRETRO_PARALLEL_N64_PLATFORM=h5

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_ODROIDN2)$(BR2_PACKAGE_BATOCERA_TARGET_VIM3),y)
	LIBRETRO_PARALLEL_N64_PLATFORM=n2

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_ODROIDGOA),y)
	LIBRETRO_PARALLEL_N64_PLATFORM=odroid
	LIBRETRO_PARALLEL_N64_BOARD=ODROIDGOA

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_TINKERBOARD),y)
	LIBRETRO_PARALLEL_N64_PLATFORM=tinkerboard

else ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_MIQI),y)
	LIBRETRO_PARALLEL_N64_PLATFORM=tinkerboard

else
	LIBRETRO_PARALLEL_N64_PLATFORM=$(LIBRETRO_PLATFORM)
endif

define LIBRETRO_PARALLEL_N64_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" -C $(@D)/ -f Makefile platform="$(LIBRETRO_PARALLEL_N64_PLATFORM)" \
		BOARD="$(LIBRETRO_PARALLEL_N64_BOARD)" $(LIBRETRO_PARALLEL_N64_EXTRA_ARGS)
endef

define LIBRETRO_PARALLEL_N64_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/parallel_n64_libretro.so \
	$(TARGET_DIR)/usr/lib/libretro/parallel_n64_libretro.so
endef

define PARALLEL_N64_CROSS_FIXUP
	$(SED) 's|/opt/vc/include|$(STAGING_DIR)/usr/include|g' $(@D)/Makefile
	$(SED) 's|/opt/vc/lib|$(STAGING_DIR)/usr/lib|g' $(@D)/Makefile
endef

PARALLEL_N64_PRE_CONFIGURE_HOOKS += PARALLEL_N64_FIXUP

$(eval $(generic-package))
