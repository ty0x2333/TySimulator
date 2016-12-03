#
# Be sure to run `pod lib lint TYAlertView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TySimulator-Kevlar'
  s.version          = '1.0'
  s.summary          = 'TySimulator Kevlar.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Similar to UIAlertView / UIAlertController, but more flexible'

  s.homepage         = 'https://github.com/luckytianyiyan/TySimulator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luckytianyiyan' => 'luckytianyiyan@gmail.com' }
  s.source           = { :git => 'https://github.com/luckytianyiyan/TySimulator.git' }
  s.social_media_url = 'https://twitter.com/luckytianyiyan'

  s.ios.deployment_target = '8.0'

  s.source_files = '*.h'
  s.vendored_library = 'libkevlar.a'

  s.platform = :osx, '10.9'
  s.libraries = 'c++'
  s.frameworks = 'Security', 'IOKit'
end
