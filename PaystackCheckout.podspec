#
# Be sure to run `pod lib lint paystack-sdk-ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PaystackCheckout'
  s.version          = '0.1.0'
  s.summary          = 'Checkout functionality from the Paystack Public iOS SDK'

# TODO: Add correct descriptions

  s.description      = "This is an iOS library used to access Paystack Checkout functionality"

  s.homepage         = 'https://github.com/PaystackHQ/paystack-sdk-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # TODO: Determine if we want to change the license type
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Paystack Mobile' => 'hello@paystack.com' }
  s.source           = { :git => 'https://github.com/PaystackHQ/paystack-sdk-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/paystack'

  s.ios.deployment_target = '13.0'
  s.swift_versions = '5.7'
  s.source_files = 'Sources/PaystackSDK/API/Checkout/**/*.{h,m,swift}'
  
  s.dependency 'Paystack'
 
end
