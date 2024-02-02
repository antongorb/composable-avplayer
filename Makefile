PLATFORM_IOS = iOS Simulator,name=iPhone 14
PLATFORM_MACOS = macOS
PLATFORM_TVOS = tvOS Simulator,name=Apple TV 4K (3rd generation) (at 1080p)
PLATFORM_WATCHOS = watchOS Simulator,name=Apple Watch Series 8 (45mm)

default: test

test:
	xcodebuild test \
		-scheme ComposableAVPlayer \
		-destination platform="$(PLATFORM_IOS)"
		-skipMacroValidation
	#xcodebuild test \
		-scheme ComposableAVPlayer \
		-destination platform="$(PLATFORM_MACOS)"
	#xcodebuild test \
		-scheme ComposableAVPlayer \
		-destination platform="$(PLATFORM_TVOS)"
	#xcodebuild \
		-scheme ComposableAVPlayer_watchOS \
		-destination platform="$(PLATFORM_WATCHOS)"
	#cd Examples/PlayerManager \
		&& xcodebuild test \
		-scheme PlayerManagerDesktop \
		-destination platform="$(PLATFORM_MACOS)"
	#cd Examples/PlayerManager \
		&& xcodebuild test \
		-scheme PlayerManagerMobile \
		-destination platform="$(PLATFORM_IOS)"

format:
	swift format --in-place --recursive \
		./Examples ./Package.swift ./Sources ./Tests

.PHONY: format test
