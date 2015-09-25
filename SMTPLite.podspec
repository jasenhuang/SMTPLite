#
#  Be sure to run `pod spec lint SMTPLite.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "SMTPLite"
  s.version      = "0.0.1"
  s.summary      = "A smtp library for object-c"
  s.homepage     = 'https://github.com/jasenhuang/smtp'
  s.license      = { :type => 'BSD' }
  s.author       = "jasenhuang"
  s.platform     = :ios, "6.0"
  s.ios.deployment_target = "6.0"
  s.source       = { :git => "https://github.com/jasenhuang/smtp.git", :tag => "0.0.1" }
  s.source_files  = "smtp/**/*.{h,m}"
  s.public_header_files = "smtp/**/*.h"
  s.libraries    = "z"
  s.requires_arc = true
  #s.vendored_libraries = 'smtp/curl/libcurl.a'

end
