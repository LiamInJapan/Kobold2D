#!/bin/sh

# buildtool = Xcode 4.2, preview = Xcode 4.1
BUILDTOOL=/Developer5/usr/bin/xcodebuild
BUILDTOOLXCODE43=/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
KKROOT=/depot-kobold2d/Kobold2D-Master/Kobold2D/
KKWORKSPACEFILE=Kobold2D.xcworkspace
KKWORKSPACE=${KKROOT}${KKWORKSPACEFILE}

# bash has got to be the most ridiculous way to perform upper/lowercase conversions
JOB_NAME_LOWERCASE="$(echo ${JOB_NAME} | tr 'A-Z' 'a-z')"

# rename derived data folder for this build job
DERIVED=___DerivedData
DERIVED=/depot-kobold2d/${DERIVED}
DERIVEDIOS5=${DERIVED}IOS5
DERIVEDIOS51=${DERIVED}IOS51

function failed()
{
    echo "Failed: $@" >&2
    
	if [ "$IOS" -eq 51 ]; then
		mv ${DERIVED} ${DERIVEDIOS51}
	fi
	if [ "$IOS" -eq 5 ]; then
		mv ${DERIVED} ${DERIVEDIOS5}
	fi
    
    exit 1
}

set -ex

COMMON_ARGS="-workspace $KKWORKSPACE -scheme $JOB_NAME ONLY_ACTIVE_ARCH=NO GCC_TREAT_WARNINGS_AS_ERRORS=YES"


if [ -d ${DERIVED} ]; then
	rm -rfd ${DERIVED}
fi


IOS=51
if [ -d ${DERIVEDIOS51} ]; then
	mv ${DERIVEDIOS51} ${DERIVED}
fi

case $JOB_NAME_LOWERCASE in
     *-ios) 
    	 echo "============ RUNNING IOS BUILDS ============"
		$BUILDTOOLXCODE43 $COMMON_ARGS -sdk iphoneos -configuration Release || failed IPHONEOS-RELEASE_XCODE43
		$BUILDTOOLXCODE43 $COMMON_ARGS -sdk iphoneos -configuration Debug || failed IPHONEOS-DEBUG_XCODE43
		$BUILDTOOLXCODE43 $COMMON_ARGS VALID_ARCHS=i386 ARCHS=i386 GCC_VERSION=com.apple.compilers.llvm.clang.1_0.compiler -sdk iphonesimulator -configuration Debug || failed IPHONESIMULATOR-DEBUG_XCODE43
     ;;
     *-mac) 
 	    echo "============ RUNNING MAC OS BUILDS ============"
		$BUILDTOOLXCODE43 $COMMON_ARGS -sdk macosx -configuration Release || failed MACOSX-RELEASE_XCODE43
		$BUILDTOOLXCODE43 $COMMON_ARGS -sdk macosx -configuration Debug || failed MACOSX-DEBUG_XCODE43
     ;;
esac

# keep the build folder for the next run
mv ${DERIVED} ${DERIVEDIOS51}


IOS=5
if [ -d ${DERIVEDIOS5} ]; then
	mv ${DERIVEDIOS5} ${DERIVED}
fi

case $JOB_NAME_LOWERCASE in
     *-ios) 
    	 echo "============ RUNNING IOS BUILDS ============"
		$BUILDTOOL $COMMON_ARGS -sdk iphoneos -configuration Release || failed IPHONEOS-RELEASE_XCODE42
		$BUILDTOOL $COMMON_ARGS -sdk iphoneos -configuration Debug || failed IPHONEOS-DEBUG_XCODE42
		$BUILDTOOL $COMMON_ARGS VALID_ARCHS=i386 ARCHS=i386 GCC_VERSION=com.apple.compilers.llvm.clang.1_0.compiler -sdk iphonesimulator -configuration Debug || failed IPHONESIMULATOR-DEBUG_XCODE42
     ;;
     *-mac) 
 	    echo "============ RUNNING MAC OS BUILDS ============"
		$BUILDTOOL $COMMON_ARGS -sdk macosx -configuration Release || failed MACOSX-RELEASE_XCODE42
		$BUILDTOOL $COMMON_ARGS -sdk macosx -configuration Debug || failed MACOSX-DEBUG_XCODE42
     ;;
esac

mv ${DERIVED} ${DERIVEDIOS5}
