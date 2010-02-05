#!/usr/bin/env ruby
`xcodebuild -sdk iphoneos3.1.3 -target PropSetter -configuration Release "ARCHS=armv6 armv7" clean build"`
`xcodebuild -sdk iphonesimulator3.1.3 -target PropSetter -configuration Release "ARCHS=i386 x86_64" "VALID_ARCHS=i386 x86_64" clean build`
`lipo -output build/libPropSetter.a -create build/Release-iphoneos/libPropSetter.a build/Release-iphonesimulator/libPropSetter.a`


