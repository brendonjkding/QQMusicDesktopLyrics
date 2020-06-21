ifdef SIMULATOR
TARGET = simulator:clang:11.2:9.0
ARCHS = x86_64
else
TARGET = iphone:clang:11.2:9.0
ARCHS= arm64 arm64e
# ARCHS= arm64
endif
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = QQMusicDesktopLyrics

QQMusicDesktopLyrics_FILES = Tweak.xm $(wildcard *.m) $(wildcard QQWQSuspendView/*.m)
QQMusicDesktopLyrics_CFLAGS = -fobjc-arc -Wno-error=unused-variable -Wno-error=unused-function
ifndef SIMULATOR
QQMusicDesktopLyrics_LIBRARIES= rocketbootstrap
endif
QQMusicDesktopLyrics_PRIVATE_FRAMEWORKS = AppSupport 

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += qqmusicdesktoplyrics
include $(THEOS_MAKE_PATH)/aggregate.mk

ifdef SIMULATOR
include $(THEOS)/makefiles/locatesim.mk
BUNDLE_NAME = qqmusicdesktoplyrics
PREF_FOLDER_NAME = $(shell echo $(BUNDLE_NAME) | tr A-Z a-z)
endif

after-install::
	install.exec "killall -9 QQMusic" ||true
# 	install.exec "sbreload" ||true
# 	install.exec "killall backboardd" ||true

ifneq (,$(filter x86_64 i386,$(ARCHS)))
setup:: all
	@rm -f /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(THEOS_OBJ_DIR)/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).dylib
	@codesign -f -s - /opt/simject/$(TWEAK_NAME).dylib
	@cp -v $(PWD)/$(TWEAK_NAME).plist /opt/simject
	$(ECHO_NOTHING)sudo cp -v $(PWD)/$(PREF_FOLDER_NAME)/entry.plist $(PL_SIMULATOR_PLISTS_PATH)/$(BUNDLE_NAME).plist$(ECHO_END)
	$(ECHO_NOTHING)sudo cp -vR $(THEOS_OBJ_DIR)/$(BUNDLE_NAME).bundle $(PL_SIMULATOR_BUNDLES_PATH)/$(ECHO_END)
	@sudo codesign -f -s - $(PL_SIMULATOR_BUNDLES_PATH)/$(BUNDLE_NAME).bundle/$(BUNDLE_NAME)
	@resim 
endif

remove:: 
	@rm -f /opt/simject/$(TWEAK_NAME).dylib /opt/simject/$(TWEAK_NAME).plist
	sudo rm -r $(PL_SIMULATOR_BUNDLES_PATH)/$(BUNDLE_NAME).bundle
	sudo rm $(PL_SIMULATOR_PLISTS_PATH)/$(BUNDLE_NAME).plist
	@resim 