#
# Be sure to run `pod lib lint Steth-IO-SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Steth-IO-SDK'
  s.version          = '0.1.1'
  s.summary          = 'A short description of Steth-IO-SDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = ' Think: What does it do? Why did you write it? What is the focus?'
  s.homepage         = 'https://github.com/StratoScientific/Steth-IO-SDK-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dhinesh-raju' => 'dhinesh.raju@ionixxtech.com' }
  s.source           = { :git => 'https://github.com/StratoScientific/Steth-IO-SDK-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

#  s.source_files = 'Steth-IO-SDK/Classes/*'
  
  # s.resource_bundles = {
  #   'Steth-IO-SDK' => ['Steth-IO-SDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
 
  s.vendored_frameworks = 'Steth-IO-SDK/Frameworks/StethIO.framework'
  # s.dependency 'AFNetworking', '~> 2.3'
  
end
