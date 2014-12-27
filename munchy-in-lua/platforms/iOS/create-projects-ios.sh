#!/bin/bash

cd `dirname $0`/..

# check for command line switches
usage="usage: $0 \
    [--use-untz true | false] [--disable-adcolony] [--disable-billing] \
    [--disable-chartboost] [--disable-crittercism] [--disable-facebook] \
    [--disable-mobileapptracker] [--disable-push] [--disable-tapjoy] \
    [--disable-twitter] [--release] \
    <lua_src_directory>"

use_untz="true"

adcolony_flags=
billing_flags=
chartboost_flags=
crittercism_flags=
facebook_flags=
push_flags=
tapjoy_flags=
twitter_flags=
buildtype_flags="Release"
windows_flags=
simulator="false"

while [ $# -gt 1 ];	do
    case "$1" in
        --use-untz)  use_untz="$2"; shift;;
        --disable-adcolony)  adcolony_flags="-DDISABLE_ADCOLONY";;
        --disable-billing)  billing_flags="-DDISABLE_BILLING";;
        --disable-chartboost)  chartboost_flags="-DDISABLE_CHARTBOOST";;
        --disable-crittercism)  crittercism_flags="-DDISABLE_CRITTERCISM";;
        --disable-facebook)  facebook_flags="-DDISABLE_FACEBOOK";;
        --disable-mobileapptracker)  mobileapptracker_flags="-DDISABLE_MOBILEAPPTRACKER";;
        --disable-push)  push_flags="-DDISABLE_NOTIFICATIONS";;
        --disable-tapjoy)  tapjoy_flags="-DDISABLE_TAPJOY";;
        --disable-twitter)  twitter_flags="-DDISABLE_TWITTER";;
        --release) buildtype_flags="Release";;
        --simulator) simulator="true";;
        -*)
            echo >&2 \
                $usage
            exit 1;;
        *)  break;;	# terminate while loop
    esac
    shift
done

SRCPARAM='./samples/hello-moai'
if [ x != x"$1" ]; then
   SRCPARAM=$1
fi
LUASRC=$(ruby -e 'puts File.expand_path(ARGV.first)' "$SRCPARAM")

if [ ! -f "${LUASRC}/main.lua" ]; then
  echo "Could not find main.lua in specified lua source directory [${LUASRC}]"
  exit 1
fi

if [ x"$use_untz" != xtrue ] && [ x"$use_untz" != xfalse ]; then
    echo $usage
    exit 1
fi

#get some required variables
XCODEPATH=$(xcode-select --print-path)

if [ x"$simulator" == xtrue ]; then
echo "RUNNING SIMULATOR $simulator"
PLATFORM_PATH=${XCODEPATH}/Platforms/iPhoneSimulator.platform/Developer
PLATFORM=SIMULATOR
SDK=iphonesimulator
ARCH=i386
else
PLATFORM_PATH=${XCODEPATH}/Platforms/iPhone.platform/Developer
PLATFORM=OS
SDK=iphoneos
ARCH=armv7
fi

SIGN_IDENTITY='iPhone Developer'

# echo message about what we are doing
echo "Building moai.app via CMAKE"

disabled_ext=
    
if [ x"$use_untz" != xtrue ]; then
    echo "UNTZ will be disabled"
    untz_param='-DMOAI_UNTZ=0'
else
    untz_param='-DMOAI_UNTZ=1'
fi 

if [ x"$adcolony_flags" != x ]; then
    echo "AdColony will be disabled"
    disabled_ext="${disabled_ext}ADCOLONY;"
fi 

if [ x"$billing_flags" != x ]; then
    echo "Billing will be disabled"
    disabled_ext="${disabled_ext}BILLING;"
fi 

if [ x"$chartboost_flags" != x ]; then
    echo "ChartBoost will be disabled"
    disabled_ext="${disabled_ext}CHARTBOOST;"
fi 

if [ x"$crittercism_flags" != x ]; then
    echo "Crittercism will be disabled"
    disabled_ext="${disabled_ext}CRITTERCISM;"
fi 

if [ x"$facebook_flags" != x ]; then
    echo "Facebook will be disabled"
    disabled_ext="${disabled_ext}FACEBOOK;"
fi 

if [ x"$mobileapptracker_flags" != x ]; then
    echo "Mobile App Tracker will be disabled"
    disabled_ext="${disabled_ext}MOBILEAPPTRACKER;"
fi 

if [ x"$push_flags" != x ]; then
    echo "Push Notifications will be disabled"
    disabled_ext="${disabled_ext}NOTIFICATIONS;"
fi 

if [ x"$tapjoy_flags" != x ]; then
    echo "Tapjoy will be disabled"
    disabled_ext="${disabled_ext}TAPJOY;"
fi 

if [ x"$twitter_flags" != x ]; then
    echo "Twitter will be disabled"
    disabled_ext="${disabled_ext}TWITTER;"
fi 

# Disable playhaven
disabled_ext="${disabled_ext}PLAYHAVEN;"

build_dir=${PWD}

 cd cmake
 mkdir projects
 cd projects
 rm -rf moai-ios
 mkdir moai-ios
 cd moai-ios
 
 echo "Building resource list from ${LUASRC}"
 ruby ../../host-ios/build_resources.rb "${LUASRC}"

 echo "Creating xcode project"

#create our makefiles
cmake -DDISABLED_EXT="$disabled_ext" -DMOAI_BOX2D=1 \
-DMOAI_CHIPMUNK=0 -DMOAI_CURL=0 -DMOAI_CRYPTO=0 -DMOAI_EXPAT=0 -DMOAI_FREETYPE=1 \
-DMOAI_HTTP_CLIENT=0 -DMOAI_JSON=1 -DMOAI_JPG=0 -DMOAI_LUAEXT=1 \
-DMOAI_MONGOOSE=0 -DMOAI_OGG=0 -DMOAI_OPENSSL=0 -DMOAI_SQLITE3=0 \
-DMOAI_TINYXML=0 -DMOAI_PNG=1 -DMOAI_SFMT=0 -DMOAI_VORBIS=0 $untz_param \
-DMOAI_LUAJIT=0 \
-DBUILD_IOS=true \
-DSIGN_IDENTITY="${SIGN_IDENTITY}" \
-DAPP_NAME="${APP_NAME}" \
-DAPP_ID="${APP_ID}" \
-DAPP_VERSION="${APP_VERSION}" \
-DCMAKE_BUILD_TYPE=$buildtype_flags \
-G "Xcode" \
../../

#-DCMAKE_TOOLCHAIN_FILE="${PWD}/../host-ios/iOS.cmake" \
#-DCMAKE_IOS_DEVELOPER_ROOT="${PLATFORM_PATH}" \
      #build them
# xcodebuild -target moai -sdk ${SDK} -arch ${ARCH} -configuration Release IPHONEOS_DEPLOYMENT_TARGET='6.1' GCC_FAST_MATH=YES LLVM_VECTORIZE_LOOPS=YES;
