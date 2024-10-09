
Pod::Spec.new do |s|
  s.name             = 'PaystackCore'
  s.version          = '0.0.4'
  s.summary          = 'The Paystack Public iOS SDK'

# TODO: Add correct descriptions

  s.description      = "This is an iOS library used to access Paystack APIs, etc."

  s.homepage         = 'https://github.com/PaystackHQ/paystack-sdk-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Paystack Mobile' => 'hello@paystack.com' }
  s.source           = { :git => 'https://github.com/PaystackHQ/paystack-sdk-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/paystack'

  s.dependency 'PusherSwift', '~> 10.1.0'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = "11.0"
  s.swift_versions = '5.7'
  s.source_files = 'Sources/PaystackSDK/**/*.{h,m,swift}'
  s.vendored_frameworks = 'PaystackPusherWrapper.xcframework'
  s.resource_bundles = {
    'PaystackSDK_PaystackCore' => [ 
       'Sources/PaystackSDK/Versioning/versions.plist',
       'Sources/PaystackSDK/Core/Service/Subscription/secrets.plist'
    ]
  }
 
end
