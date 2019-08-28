#
# Be sure to run `pod lib lint googlyeyes.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'googlyeyes'
  s.version          = '0.9.1'
  s.summary          = 'Here is looking at you.'
  s.description      = 'UIKit was short a decent googly eye'
  s.homepage         = 'https://github.com/morkrom/googlyeyes'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Michael Mork' => 'morkrom@protonmail.ch' }
  s.source           = { :git => 'https://github.com/morkrom/googlyeyes.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/googly-eyes'
  s.ios.deployment_target = '9.0'
  s.swift_version    = '5.0'
  s.source_files = 'googlyeyes/Classes/**/*'
  
end
