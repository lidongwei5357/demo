#
# Be sure to run `pod lib lint MyDemoLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MyDemoLib'
  s.version          = '1.1.2'
  s.summary          = 'A short description of MyDemoLib.'
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com/lidongwei/MyDemoLib'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           =  'lidongwei'
  s.source           = { :git => 'https://github.com/lidongwei5357/demo.git', :tag => s.version.to_s }
  
  s.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64' }
  
  s.requires_arc = true
  s.swift_version = '5.0'
  
  s.dependency 'SnapKit', '5.0.1'
  s.dependency 'Toast-Swift', '5.0.0'
  s.dependency 'IQAudioRecorderController', '1.2.3'
  s.dependency 'IQKeyboardManagerSwift', '6.5.4'
  s.dependency 'SQLite.swift', '0.12.2'
  s.dependency 'KeychainSwift', '18.0.0'
  s.dependency 'Alamofire', '4.9.1'
  s.dependency 'MBProgressHUD', '1.1.0'
  
   #使用了:path或:git直接引用源码时可能忽略默认子规范‌
  s.default_subspec = 'Lib'
  
   #源码模式配置
  s.subspec 'Source' do |ss|
    ss.source_files = 'MyDemoLib/Classes/**/*'
    ss.resource_bundles = {
      'MyDemoLib' => ['MyDemoLib/Resources/*.xcassets','MyDemoLib/Resources/**/*.strings',
      'MyDemoLib/Resources/PrivacyInfo.xcprivacy']
    }
  end
  
  # 二进制模式配置
  s.subspec 'Lib' do |ss|
    ss.vendored_frameworks = 'Framework/MyDemoLib.xcframework'
    ss.preserve_paths      = 'Framework/*'
  end
  
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  
  
end
