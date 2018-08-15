# 工程名
APP_NAME="YGXWebViewController"
# 证书
CODE_SIGN_DISTRIBUTION="iPhone Distribution: Xiamen Meitu Technology Co., Ltd"
# info.plist路径
project_infoplist_path="./${APP_NAME}/Info.plist"

#取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${project_infoplist_path}")

#取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${project_infoplist_path}")

DATE="$(date +%Y%m%d)"
IPANAME="${APP_NAME}_V${bundleShortVersion}_${DATE}.ipa"

#要上传的ipa文件路径
IPA_PATH="$(PWD)/ipa"
if [[ -ne $IPA_PATH ]]; then
	mkdir $IPA_PATH
fi
IPA_PATH="$IPA_PATH/${IPANAME}"
echo ${IPA_PATH}
echo "${IPA_PATH}">> text.txt

#获取权限
# security unlock-keychain -p "打包机器登录密码" $HOME/Library/Keychains/login.keychain
# //下面2行是没有Cocopods的用法
# echo "=================clean================="
# xcodebuild -target "${APP_NAME}"  -configuration 'Release' clean

# echo "+++++++++++++++++build+++++++++++++++++"
# xcodebuild -target "${APP_NAME}" -sdk iphoneos -configuration 'Release' CODE_SIGN_IDENTITY="${CODE_SIGN_DISTRIBUTION}" SYMROOT='$(PWD)'

#//下面2行是集成有Cocopods的用法
# echo "=================clean================="
# xcodebuild -workspace "${APP_NAME}.xcworkspace" -scheme "${APP_NAME}"  -configuration 'Debug' clean

# echo "+++++++++++++++++build+++++++++++++++++"
# xcodebuild -workspace "${APP_NAME}.xcworkspace" -scheme "${APP_NAME}" -sdk iphoneos -configuration 'Debug' CODE_SIGN_IDENTITY="${CODE_SIGN_DISTRIBUTION}" SYMROOT='$(PWD)'

# echo "================= start package ================="
# xcrun -sdk iphoneos PackageApplication "./Debug-iphoneos/${APP_NAME}.app" -o ${IPA_PATH}

# new pkg
xcodebuild -workspace "${APP_NAME}.xcworkspace" -scheme "${APP_NAME}"  -configuration 'Debug' clean
#archive
xcodebuild -workspace "${APP_NAME}.xcworkspace" -scheme "${APP_NAME}" -sdk iphoneos -configuration 'Debug' CODE_SIGN_IDENTITY="${CODE_SIGN_DISTRIBUTION}" SYMROOT='$(PWD)' archive -archivePath ./${IPANAME}.xcarchive
#export
xcodebuild -exportArchive -archivePath ${IPANAME}.xcarchive -exportOptionsPlist e.plist -exportPath ./