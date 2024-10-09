
Pod::Spec.new do |s|
  s.name             = 'PaystackUI'
  s.version          = '0.0.4'
  s.summary          = 'The UI Flows build upon the Paystack Public iOS SDK'

# TODO: Add correct descriptions

  s.description      = "This is an iOS library used to access Paystack provided UI Flows that interact with our APIs"

  s.homepage         = 'https://github.com/PaystackHQ/paystack-sdk-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Paystack Mobile' => 'hello@paystack.com' }
  s.source           = { :git => 'https://github.com/PaystackHQ/paystack-sdk-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/paystack'

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = "11.0"
  s.swift_versions = '5.7'
  s.source_files = 'Sources/PaystackUI/**/*.{h,m,swift}'
  s.resources = 'Sources/PaystackUI/**/*.{lproj,ttf,json}'
  s.resource_bundles = {
    'PaystackSDK_PaystackUI' => [ 
       'Sources/PaystackUI/Images/Images.xcassets',
       'Sources/PaystackUI/Design/ColorAssets/Colors.xcassets'
    ]
  }

  s.dependency 'PaystackCore'
 
end
