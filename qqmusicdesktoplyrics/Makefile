ifdef SIMULATOR
TARGET = simulator:clang:11.2:9.0
ARCHS = x86_64
else
TARGET = iphone:clang:11.2:9.0
ARCHS= arm64 arm64e
endif
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = qqmusicdesktoplyrics

qqmusicdesktoplyrics_FILES = QMDLPrefRootListController.m BDInfoListController.m
qqmusicdesktoplyrics_INSTALL_PATH = /Library/PreferenceBundles
qqmusicdesktoplyrics_FRAMEWORKS = UIKit
qqmusicdesktoplyrics_PRIVATE_FRAMEWORKS = Preferences
qqmusicdesktoplyrics_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/qqmusicdesktoplyrics.plist$(ECHO_END)
