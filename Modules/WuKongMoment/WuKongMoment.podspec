#
# Be sure to run `pod lib lint WuKongMoment.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WuKongMoment'
  s.version          = '0.1.0'
  s.summary          = 'A short description of WuKongMoment.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/tangtaoit/WuKongMoment'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tangtaoit' => 'tt@tgo.ai' }
  s.source           = { :git => 'https://github.com/tangtaoit/WuKongMoment.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'WuKongMoment/Classes/**/*'
  s.private_header_files = 'WuKongMoment/Classes/Vendor/**/*'
  
  s.resource_bundles = {
    'WuKongMoment_images' => ['WuKongMoment/Assets/Images.xcassets'],
    'WuKongMoment_resources' => ['WuKongMoment/Assets/DB']
  }
  s.resources = ['WuKongMoment/Assets/Lang']
  
  s.dependency 'WuKongBase'
  s.dependency 'WuKongIMSDK'
  s.dependency 'SDWebImage','~> 5.9.1'
end
