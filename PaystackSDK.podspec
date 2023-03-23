
Pod::Spec.new do |s|
  s.name             = 'PaystackSDK'
  s.version          = '0.1.0'
  s.summary          = 'The Paystack Public iOS SDK'

# TODO: Add correct descriptions

  s.description      = "This is an iOS library used to access Paystack APIs, etc."

  s.homepage         = 'https://github.com/PaystackHQ/paystack-sdk-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # TODO: Determine if we want to change the license type
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Paystack Mobile' => 'hello@paystack.com' }
  s.source           = { :git => 'https://github.com/PaystackHQ/paystack-sdk-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/paystack'

  s.ios.deployment_target = '12.0'
  s.swift_versions = '5.7'
  s.source_files = 'Sources/PaystackSDK/**/*.{h,m,swift}'
 
end
