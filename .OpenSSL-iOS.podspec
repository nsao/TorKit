Pod::Spec.new do |s|
	s.name = 'OpenSSL-iOS'
    	s.version = "1.0.1e"
    	s.summary = 'The OpenSSL Project is a collaborative effort to develop a robust, commercial-grade, full-featured, and Open Source toolkit implementing the Secure Sockets Layer (SSL v2/v3) and Transport Layer Security (TLS v1) protocols as well as a full-strength general purpose cryptography library managed by a worldwide community of volunteers that use the Internet to communicate, plan, and develop the OpenSSL toolkit and its related documentation.'
   	s.homepage = 'http://www.openssl.org'
	s.author = 'The OpenSSL Team'
    	s.source = { :http => 'http://www.openssl.org/source/openssl-1.0.1e.tar.gz' }
    	s.platform = :ios, '6.1'
  	s.source_files = 'include/openssl/**/*.h'
  	s.public_header_files = 'include/openssl/**/.h'
  	s.preserve_paths = 'lib/libcrypto.a', 'lib/libssl.a'
  	s.xcconfig	 = { 'LIBRARY_SEARCH_PATHS' => '"$(SRCROOT)/Pods/OpenSSL/lib"' }
  	s.library = 'crypto', 'ssl'
    	s.pre_install do |pod, target_definition|
		Dir.chdir(pod.root) 
		unless !File.exists?('lib/libssl.a') && !File.exists?('lib/libcrypto.a')

			puts "[!] Building #{s.name} for iOS (this may  take some time, for real)...".yellow
        		system <<EOC
#!/bin/bash
# https://github.com/st3fan/ios-openssl/blob/master/build.sh
# Yay shell scripting! This script builds a static version of
# OpenSSL ${OPENSSL_VERSION} for iOS 5.1 that contains code for armv6, armv7 and i386.

# Setup paths to stuff we need

OPENSSL_VERSION="1.0.1e"

DEVELOPER=`xcode-select -print-path`
OUTPUTDIR="`pwd`/lipo"
SDK_VERSION="6.1"
PODROOT=`pwd`

IPHONEOS_PLATFORM="${DEVELOPER}/Platforms/iPhoneOS.platform"
IPHONEOS_SDK="${IPHONEOS_PLATFORM}/Developer/SDKs/iPhoneOS${SDK_VERSION}.sdk"
IPHONEOS_GCC="${IPHONEOS_PLATFORM}/Developer/usr/bin/gcc"

IPHONESIMULATOR_PLATFORM="${DEVELOPER}/Platforms/iPhoneSimulator.platform"
IPHONESIMULATOR_SDK="${IPHONESIMULATOR_PLATFORM}/Developer/SDKs/iPhoneSimulator${SDK_VERSION}.sdk"
IPHONESIMULATOR_GCC="${IPHONESIMULATOR_PLATFORM}/Developer/usr/bin/gcc"

# Clean up whatever was left from our previous build

rm -rf include lib

build()
{
   tar xfz "file.tgz"
   ARCH=$1
   GCC=$2
   SDK=$3
   cd "openssl-${OPENSSL_VERSION}"
   ./Configure BSD-generic32 --openssldir="$OUTPUTDIR/openssl-${OPENSSL_VERSION}-${ARCH}" > /dev/null 2>&1
   perl -i -pe 's|static volatile sig_atomic_t intr_signal|static volatile int intr_signal|' crypto/ui/ui_openssl.c
   perl -i -pe "s|^CC= gcc|CC= ${GCC} -arch ${ARCH}|g" Makefile
   perl -i -pe "s|^CFLAG= (.*)|CFLAG= -isysroot ${SDK}|g" Makefile
   make  > /dev/null 2>&1
   make install  > /dev/null 2>&1
   cd "${PODROOT}"
   rm -rf "openssl-${OPENSSL_VERSION}"
}


build "armv7" "${IPHONEOS_GCC}" "${IPHONEOS_SDK}"
build "armv7s" "${IPHONEOS_GCC}" "${IPHONEOS_SDK}"
build "i386" "${IPHONESIMULATOR_GCC}" "${IPHONESIMULATOR_SDK}"

#

mkdir include
cp -r $OUTPUTDIR/openssl-${OPENSSL_VERSION}-i386/include/openssl include/

mkdir lib
lipo \
	"$OUTPUTDIR/openssl-${OPENSSL_VERSION}-armv7/lib/libcrypto.a" \
	"$OUTPUTDIR/openssl-${OPENSSL_VERSION}-armv7s/lib/libcrypto.a" \
	"$OUTPUTDIR/openssl-${OPENSSL_VERSION}-i386/lib/libcrypto.a" \
	-create -output lib/libcrypto.a
lipo \
	"$OUTPUTDIR/openssl-${OPENSSL_VERSION}-armv7/lib/libssl.a" \
	"$OUTPUTDIR/openssl-${OPENSSL_VERSION}-armv7s/lib/libssl.a" \
	"$OUTPUTDIR/openssl-${OPENSSL_VERSION}-i386/lib/libssl.a" \
	-create -output lib/libssl.a


EOC

	end
    end
end

