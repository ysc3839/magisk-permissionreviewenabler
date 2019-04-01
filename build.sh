#!/bin/bash

[ -z "$ANDROID_HOME" ] && {
  echo `$ANDROID_HOME not found!`
  exit 1
}

export PATH="$ANDROID_HOME/build-tools/28.0.2":$PATH

pushd app
aapt package -M AndroidManifest.xml -S res/ \
  -I "$ANDROID_HOME/platforms/android-28/android.jar" \
  -F PermissionReviewEnabler.apk || exit 1

mv PermissionReviewEnabler.apk ..
popd

pushd magisk
mv ../PermissionReviewEnabler.apk system/vendor/overlay/PermissionReviewEnabler/
rm system/vendor/overlay/PermissionReviewEnabler/placeholder

find -exec touch -d @0 -h {} +
find -type d -exec chmod 0755 {} +
find -type f -exec chmod 0644 {} +

version=$(grep -Po "version=\K.*" module.prop)
zip -r -y -9 ../magisk-permissionreviewenabler-$version.zip . || exit 1
popd
