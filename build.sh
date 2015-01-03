#!/bin/bash
BUILD=$(which xcodebuild)
SDK='iphoneos8.1'

if [ "$1" != "nobuild" ]; then	
#$BUILD clean install

#$BUILD ARCHS='armv7 armv7s arm64' ONLY_ACTIVE_ARCH=NO -sdk "$SDK" -configuration Release -alltargets clean

# Uncomment to enable CLUTCH_DEBUG and DEV with release
$BUILD ARCHS='armv7 armv7s arm64' ONLY_ACTIVE_ARCH=NO -sdk "$SDK" -workspace 'BetterRIP.xcworkspace' -configuration Release -scheme 'Proclivity' -derivedDataPath 'build'
if [ $? != 0 ]; then
	echo "Error building"
	exit
fi
sudo rm -r .deb
fi

mkdir -p .deb/DEBIAN
mkdir -p .deb/Applications
mkdir -p .deb/usr/libexec
mv build/Build/Products/Release-iphoneos/Proclivity.app .deb/Applications
mv .deb/Applications/Proclivity.app/Proclivity .deb/Applications/Proclivity.app/Proclivity_

cp fixuid.sh .deb/Applications/Proclivity.app/Proclivity

echo "Need root to chown"
chmod 775 .deb/Applications/Proclivity.app/Proclivity
sudo chown root .deb/Applications/Proclivity.app/Proclivity
chmod 6775 .deb/Applications/Proclivity.app/Proclivity_

version="0.1.0"

cat > .deb/DEBIAN/control <<EOF
Package: com.alpharise.proclivity
Depends: dpkg
Name: Proclivity
Version: $version
Architecture: iphoneos-arm
Description: Beautiful,speed-oriented package manager
Homepage: http://google.com.sg
Maintainer: Alpharise Development <un@cracksby.kim>
Author: Alpharise Development <un@cracksby.kim>
Section: Alpharise
EOF

#cp postinst .deb/DEBIAN/
#cat > .deb/DEBIAN/postinst <<EOF
##!/bin/sh
#ln -s /usr/bin/ed /bin/ed
#chmod u+s /Applications/ripBigBoss.app/ripBigBoss_
#chown root /Applications/ripBigBoss.app/ripBigBoss_
#mkdir -p /var/root/Documents/Downloads
#EOF

chmod 775 .deb/DEBIAN/postinst

dpkg-deb -b .deb "com.alpharise.proclivity-$version-iphoneos-arm.deb"


