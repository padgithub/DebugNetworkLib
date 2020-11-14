#
#  Be sure to run `pod spec lint DebugNetworkLib.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "DebugNetworkLib"
  spec.version      = "0.0.1"
  spec.summary      = "Debug network for iOS."

  spec.description  = <<-DESC
  Debug network for iOS
                   DESC

  spec.homepage     = "https://github.com/padgithub/DebugNetworkLib"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Anh Dung" => "dungqb00@gmail.com" }

  spec.ios.deployment_target = "11.0"
  spec.swift_version = "5"

  spec.source        = { :git => "https://github.com/padgithub/DebugNetworkLib.git", :tag => "#{spec.version}" }
  spec.source_files  = "DebugNetworkLib/**/*.{h,m,swift}"
  spec.dependency 'Socket.IO-Client-Swift', '~> 15.2.0'
end