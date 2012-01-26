#!/bin/sh

IOS=4

BUILDTOOL=/Developer5/usr/bin/xcodebuild
PREVIEWBUILDTOOL=/Developer/usr/bin/xcodebuild
KKROOT=/depot-kobold2d/Kobold2D-Master/Kobold2D/
KKWORKSPACEFILE=Kobold2D.xcworkspace
KKWORKSPACE=${KKROOT}${KKWORKSPACEFILE}

# bash has got to be the most ridiculous way to perform upper/lowercase conversions
JOB_NAME_LOWERCASE="$(echo ${JOB_NAME} | tr 'A-Z' 'a-z')"

# rename derived data folder for this build job
DERIVED=___DerivedData
DERIVED=${KKROOT}${DERIVED}
DERIVEDIOS4=${DERIVED}IOS4
DERIVEDIOS5=${DERIVED}IOS5
BUILDDIR=${KKROOT}__${JOB_NAME_LOWERCASE}

function failed()
{
    echo "Failed: $@" >&2
    
	if [ "$IOS" -eq 4 ]; then
		mv ${DERIVED} ${DERIVEDIOS4}
	fi
	if [ "$IOS" -eq 5 ]; then
		mv ${DERIVED} ${DERIVEDIOS5}
	fi
    
    exit 1
}

set -ex

COMMON_ARGS="-workspace $KKWORKSPACE -scheme $JOB_NAME ONLY_ACTIVE_ARCH=NO GCC_TREAT_WARNINGS_AS_ERRORS=YES"
#PREVIEW_ARGS="OBJROOT=/depot-kobold2d/Kobold2D-Master/Kobold2D/___ObjRootForIOS5"

# SYMROOT=$BUILDDIR OBJROOT=$BUILDDIR SHARED_PRECOMPS_DIR=$BUILDDIR/SharedPrecompiledHeaders
# CACHE_ROOT=$BUILDDIR/CACHE CONFIGURATION_BUILD_DIR=$BUILDDIR/ConfigBuildDir CONFIGURATION_TEMP_DIR=$BUILDDIR/ConfigTempDir DSTROOT=$BUILDDIR/DestRoot INSTALL_DIR=$BUILDDIR/Install DERIVED_FILE_DIR=$BUILDDIR/DerivedFiles  TARGET_BUILD_DIR=$BUILDDIR/TargetBuildDir  PROJECT_TEMP_DIR=$BUILDDIR/ProjectTempDir  BUILT_PRODUCTS_DIR=$BUILDDIR/BuiltProducts TARGET_TEMP_DIR=$BUILDDIR/TargetTempDir  OBJECT_FILE_DIR=$BUILDDIR/ObjectFiles


if [ -d ${DERIVED} ]; then
	rm -rfd ${DERIVED}
fi

if [ -d ${DERIVEDIOS4} ]; then
	mv ${DERIVEDIOS4} ${DERIVED}
fi

case $JOB_NAME_LOWERCASE in
     *-ios) 
    	 echo "============ RUNNING IOS BUILDS ============"
		$PREVIEWBUILDTOOL $COMMON_ARGS -sdk iphoneos -configuration Release || failed IPHONEOS-RELEASE_XCODE42
		$PREVIEWBUILDTOOL $COMMON_ARGS -sdk iphoneos -configuration Debug || failed IPHONEOS-DEBUG_XCODE42
		$PREVIEWBUILDTOOL $COMMON_ARGS VALID_ARCHS=i386 ARCHS=i386 GCC_VERSION=com.apple.compilers.llvm.clang.1_0.compiler -sdk iphonesimulator -configuration Debug || failed IPHONESIMULATOR-DEBUG_XCODE42
     ;;
     *-mac) 
 	    echo "============ RUNNING MAC OS BUILDS ============"
		$PREVIEWBUILDTOOL $COMMON_ARGS -sdk macosx -configuration Release || failed MACOSX-RELEASE_XCODE42
		$PREVIEWBUILDTOOL $COMMON_ARGS -sdk macosx -configuration Debug || failed MACOSX-DEBUG_XCODE42
     ;;
esac

# keep the build folder for the next run
mv ${DERIVED} ${DERIVEDIOS4}


IOS=5
if [ -d ${DERIVEDIOS5} ]; then
	mv ${DERIVEDIOS5} ${DERIVED}
fi

case $JOB_NAME_LOWERCASE in
     *-ios) 
    	 echo "============ RUNNING IOS BUILDS ============"
		$BUILDTOOL $COMMON_ARGS -sdk iphoneos -configuration Release || failed IPHONEOS-RELEASE_XCODE41
		$BUILDTOOL $COMMON_ARGS -sdk iphoneos -configuration Debug || failed IPHONEOS-DEBUG_XCODE41
		$BUILDTOOL $COMMON_ARGS VALID_ARCHS=i386 ARCHS=i386 GCC_VERSION=com.apple.compilers.llvm.clang.1_0.compiler -sdk iphonesimulator -configuration Debug || failed IPHONESIMULATOR-DEBUG_XCODE41
     ;;
     *-mac) 
 	    echo "============ RUNNING MAC OS BUILDS ============"
		$BUILDTOOL $COMMON_ARGS -sdk macosx -configuration Release || failed MACOSX-RELEASE_XCODE41
		$BUILDTOOL $COMMON_ARGS -sdk macosx -configuration Debug || failed MACOSX-DEBUG_XCODE41
     ;;
esac

mv ${DERIVED} ${DERIVEDIOS5}
