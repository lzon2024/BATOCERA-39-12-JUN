################################################################################
#
# arm-trusted-firmware
#
################################################################################

ARM_TRUSTED_FIRMWARE_VERSION = $(call qstrip,$(BR2_TARGET_ARM_TRUSTED_FIRMWARE_VERSION))

ifeq ($(ARM_TRUSTED_FIRMWARE_VERSION),custom)
# Handle custom ATF tarballs as specified by the configuration
ARM_TRUSTED_FIRMWARE_TARBALL = $(call qstrip,$(BR2_TARGET_ARM_TRUSTED_FIRMWARE_CUSTOM_TARBALL_LOCATION))
ARM_TRUSTED_FIRMWARE_SITE = $(patsubst %/,%,$(dir $(ARM_TRUSTED_FIRMWARE_TARBALL)))
ARM_TRUSTED_FIRMWARE_SOURCE = $(notdir $(ARM_TRUSTED_FIRMWARE_TARBALL))
else ifeq ($(BR2_TARGET_ARM_TRUSTED_FIRMWARE_CUSTOM_GIT),y)
ARM_TRUSTED_FIRMWARE_SITE = $(call qstrip,$(BR2_TARGET_ARM_TRUSTED_FIRMWARE_CUSTOM_REPO_URL))
ARM_TRUSTED_FIRMWARE_SITE_METHOD = git
else
# Handle stable official ATF versions
ARM_TRUSTED_FIRMWARE_SITE = $(call github,ARM-software,arm-trusted-firmware,$(ARM_TRUSTED_FIRMWARE_VERSION))
# The licensing of custom or from-git versions is unknown.
# This is valid only for the official v1.4.
ARM_TRUSTED_FIRMWARE_LICENSE = BSD-3-Clause
ARM_TRUSTED_FIRMWARE_LICENSE_FILES = license.rst
endif

ifeq ($(BR2_TARGET_ARM_TRUSTED_FIRMWARE)$(BR2_TARGET_ARM_TRUSTED_FIRMWARE_LATEST_VERSION),y)
BR_NO_CHECK_HASH_FOR += $(ARM_TRUSTED_FIRMWARE_SOURCE)
endif

ARM_TRUSTED_FIRMWARE_INSTALL_IMAGES = YES

ARM_TRUSTED_FIRMWARE_PLATFORM = $(call qstrip,$(BR2_TARGET_ARM_TRUSTED_FIRMWARE_PLATFORM))

ifeq ($(BR2_TARGET_ARM_TRUSTED_FIRMWARE_DEBUG),y)
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += DEBUG=1
ARM_TRUSTED_FIRMWARE_IMG_DIR = $(@D)/build/$(ARM_TRUSTED_FIRMWARE_PLATFORM)/debug
else
ARM_TRUSTED_FIRMWARE_IMG_DIR = $(@D)/build/$(ARM_TRUSTED_FIRMWARE_PLATFORM)/release
endif

ARM_TRUSTED_FIRMWARE_MAKE_OPTS += \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	$(call qstrip,$(BR2_TARGET_ARM_TRUSTED_FIRMWARE_ADDITIONAL_VARIABLES)) \
	PLAT=$(ARM_TRUSTED_FIRMWARE_PLATFORM)

ifeq ($(BR2_ARM_CPU_ARMV7A),y)
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += ARM_ARCH_MAJOR=7
else ifeq ($(BR2_ARM_CPU_ARMV8A),y)
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += ARM_ARCH_MAJOR=8
endif

ifeq ($(BR2_arm),y)
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += ARCH=aarch32
else ifeq ($(BR2_aarch64),y)
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += ARCH=aarch64
endif

ifeq ($(BR2_TARGET_ARM_TRUSTED_FIRMWARE_BL32_OPTEE),y)
ARM_TRUSTED_FIRMWARE_DEPENDENCIES += optee-os
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += \
	BL32=$(BINARIES_DIR)/tee-header_v2.bin \
	BL32_EXTRA1=$(BINARIES_DIR)/tee-pager_v2.bin \
	BL32_EXTRA2=$(BINARIES_DIR)/tee-pageable_v2.bin
ifeq ($(BR2_aarch64),y)
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += SPD=opteed
endif
ifeq ($(BR2_arm),y)
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += AARCH32_SP=optee
endif
endif # BR2_TARGET_ARM_TRUSTED_FIRMWARE_BL32_OPTEE

ifeq ($(BR2_TARGET_ARM_TRUSTED_FIRMWARE_UBOOT_AS_BL33),y)
ARM_TRUSTED_FIRMWARE_UBOOT_BIN = $(call qstrip,$(BR2_TARGET_ARM_TRUSTED_FIRMWARE_UBOOT_BL33_IMAGE))
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += BL33=$(BINARIES_DIR)/$(ARM_TRUSTED_FIRMWARE_UBOOT_BIN)
ARM_TRUSTED_FIRMWARE_DEPENDENCIES += uboot
endif

ifeq ($(BR2_TARGET_VEXPRESS_FIRMWARE),y)
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += SCP_BL2=$(BINARIES_DIR)/scp-fw.bin
ARM_TRUSTED_FIRMWARE_DEPENDENCIES += vexpress-firmware
endif

ifeq ($(BR2_TARGET_BINARIES_MARVELL),y)
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += SCP_BL2=$(BINARIES_DIR)/scp-fw.bin
ARM_TRUSTED_FIRMWARE_DEPENDENCIES += binaries-marvell
endif

ifeq ($(BR2_TARGET_MV_DDR_MARVELL),y)
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += MV_DDR_PATH=$(MV_DDR_MARVELL_DIR)
ARM_TRUSTED_FIRMWARE_DEPENDENCIES += mv-ddr-marvell
endif

ARM_TRUSTED_FIRMWARE_MAKE_TARGETS = all

ifeq ($(BR2_TARGET_ARM_TRUSTED_FIRMWARE_FIP),y)
ARM_TRUSTED_FIRMWARE_MAKE_TARGETS += fip
ARM_TRUSTED_FIRMWARE_DEPENDENCIES += host-openssl
# fiptool only exists in newer (>= 1.3) versions of ATF, so we build
# it conditionally. We need to explicitly build it as it requires
# OpenSSL, and therefore needs to be passed proper variables to find
# the host OpenSSL.
define ARM_TRUSTED_FIRMWARE_BUILD_FIPTOOL
	if test -d $(@D)/tools/fiptool; then \
		$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/tools/fiptool \
			$(ARM_TRUSTED_FIRMWARE_MAKE_OPTS) \
			CPPFLAGS="$(HOST_CPPFLAGS)" \
			LDLIBS="$(HOST_LDFLAGS) -lcrypto" ; \
	fi
endef
endif

ifeq ($(BR2_TARGET_ARM_TRUSTED_FIRMWARE_BL31),y)
ARM_TRUSTED_FIRMWARE_MAKE_TARGETS += bl31
endif

ifeq ($(BR2_TARGET_ARM_TRUSTED_FIRMWARE_BL31_UBOOT),y)
define ARM_TRUSTED_FIRMWARE_BL31_UBOOT_BUILD
# Get the entry point address from the elf.
	BASE_ADDR=$$($(TARGET_READELF) -h $(ARM_TRUSTED_FIRMWARE_IMG_DIR)/bl31/bl31.elf | \
	             sed -r '/^  Entry point address:\s*(.*)/!d; s//\1/') && \
	$(MKIMAGE) \
		-A $(MKIMAGE_ARCH) -O arm-trusted-firmware -C none \
		-a $${BASE_ADDR} -e $${BASE_ADDR} \
		-d $(ARM_TRUSTED_FIRMWARE_IMG_DIR)/bl31.bin \
		$(ARM_TRUSTED_FIRMWARE_IMG_DIR)/atf-uboot.ub
endef
define ARM_TRUSTED_FIRMWARE_BL31_UBOOT_INSTALL
	$(INSTALL) -m 0644 $(ARM_TRUSTED_FIRMWARE_IMG_DIR)/atf-uboot.ub \
		$(BINARIES_DIR)/atf-uboot.ub
endef
ARM_TRUSTED_FIRMWARE_MAKE_OPTS += RESET_TO_BL31=1
ARM_TRUSTED_FIRMWARE_DEPENDENCIES += host-uboot-tools
endif

ifeq ($(BR2_TARGET_UBOOT_NEEDS_ATF_BL31_ELF),y)
define ARM_TRUSTED_FIRMWARE_BL31_UBOOT_INSTALL_ELF
	$(INSTALL) -D -m 0644 $(ARM_TRUSTED_FIRMWARE_IMG_DIR)/bl31/bl31.elf \
		$(BINARIES_DIR)/bl31.elf
endef
endif

define ARM_TRUSTED_FIRMWARE_BUILD_CMDS
	$(ARM_TRUSTED_FIRMWARE_BUILD_FIPTOOL)
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(ARM_TRUSTED_FIRMWARE_MAKE_OPTS) \
		$(ARM_TRUSTED_FIRMWARE_MAKE_TARGETS)
	$(ARM_TRUSTED_FIRMWARE_BL31_UBOOT_BUILD)
endef

define ARM_TRUSTED_FIRMWARE_INSTALL_IMAGES_CMDS
	$(foreach f,$(call qstrip,$(BR2_TARGET_ARM_TRUSTED_FIRMWARE_IMAGES)), \
		cp -dpf $(ARM_TRUSTED_FIRMWARE_IMG_DIR)/$(f) $(BINARIES_DIR)/
	)
	$(ARM_TRUSTED_FIRMWARE_BL31_UBOOT_INSTALL)
	$(ARM_TRUSTED_FIRMWARE_BL31_UBOOT_INSTALL_ELF)
endef

# Configuration check
ifeq ($(BR2_TARGET_ARM_TRUSTED_FIRMWARE)$(BR_BUILDING),yy)

ifeq ($(ARM_TRUSTED_FIRMWARE_VERSION),custom)
ifeq ($(call qstrip,$(BR2_TARGET_ARM_TRUSTED_FIRMWARE_CUSTOM_TARBALL_LOCATION))),)
$(error No tarball location specified. Please check BR2_TARGET_ARM_TRUSTED_FIRMWARE_CUSTOM_TARBALL_LOCATION))
endif
endif

ifeq ($(BR2_TARGET_ARM_TRUSTED_FIRMWARE_CUSTOM_GIT),y)
ifeq ($(call qstrip,$(BR2_TARGET_ARM_TRUSTED_FIRMWARE_CUSTOM_REPO_URL)),)
$(error No repository specified. Please check BR2_TARGET_ARM_TRUSTED_FIRMWARE_CUSTOM_REPO_URL)
endif
endif

endif

$(eval $(generic-package))
