export ARCHS = armv7 arm64 arm64e
export TARGET = iphone:clang:12.1.1:8.0
DEBUG = 0
FINALPACKAGE = 1
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libjelbrekicu
libjelbrekicu_FILES = $(wildcard *.m)
libjelbrekicu_CFLAGS = -fobjc-arc
libjelbrekicu_LINKAGE_TYPE = static

include $(THEOS_MAKE_PATH)/library.mk

purge::
	@rm -Rf .theos packages
	@find . -name .DS_Store -delete
	$(ECHO_BEGIN)$(PRINT_FORMAT_RED) "Purging"$(ECHO_END); $(ECHO_PIPEFAIL)
