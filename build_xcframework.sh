#!/bin/zsh

# 参数检查
if [ $# -ne 2 ]; then
  echo "Usage: $0 <module_name> <version>"
  echo "Example: $0 ModuleA 1.0.1"
  exit 1
fi

MODULE_NAME=$1
VERSION=$2

echo "🛠 开始构建 $MODULE_NAME xcframework (v$VERSION)..."

# 清理历史构建
rm -rf Framework/

# 1. 构建真机+模拟器框架
xcodebuild archive \
  -workspace Example/$MODULE_NAME.xcworkspace \
  -scheme $MODULE_NAME \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath Framework/iphoneos.xcarchive \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
  -workspace Example/$MODULE_NAME.xcworkspace \
  -scheme $MODULE_NAME \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -archivePath Framework/iphonesimulator.xcarchive \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# 2. 合成 xcframework
xcodebuild -create-xcframework \
  -framework Framework/iphoneos.xcarchive/Products/Library/Frameworks/$MODULE_NAME.framework \
  -framework Framework/iphonesimulator.xcarchive/Products/Library/Frameworks/$MODULE_NAME.framework \
  -output Framework/$MODULE_NAME.xcframework

# 3. 打包资源文件（可选）
if [ -d "$MODULE_NAME/Resources" ]; then
  mkdir -p Framework/$MODULE_NAME.bundle
  cp -R Sources/Resources/* Framework/$MODULE_NAME.bundle/
fi

echo "📦 压缩 xcframework..."

# 4. 生成版本压缩包
zip -r Framework/$MODULE_NAME-$1.xcframework.zip Framework/$MODULE_NAME.xcframework Framework/$MODULE_NAME.bundle

# 5. 更新 podspec 版本
sed -i '' "s/s.version          = .*/s.version          = '$2'/" $MODULE_NAME.podspec

echo "✅ $MODULE_NAME xcframework制作完成！版本 $VERSION "


# ------ Git 提交阶段 ------
#echo "🔖 提交到 Git 仓库..."
#git add Framework/ModuleA-$VERSION.xcframework.zip
#git commit -m "Release binary $VERSION"
#git tag $VERSION
#git push origin $VERSION
#
#echo "✅ 完成！版本 $VERSION 已发布"
