Pod::Spec.new do |s|

  s.name         = "SMTPLite"
  s.version      = "0.0.1"
  s.summary      = "A smtp library for object-c"
  s.homepage     = 'https://github.com/jasenhuang/smtp'
  s.license      = { :type => 'BSD' }
  s.author       = { 'jasenhuang' => 'jasenhuang@rdgz.org' }
  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://github.com/jasenhuang/smtp.git", :tag => "0.0.1" }
  s.source_files  = "smtp/**/*.{h,m}"
  s.public_header_files = "smtp/**/*.h"
  s.libraries    = "z"
  s.requires_arc = true
  s.vendored_libraries = 'smtp/curl/libcurl.a'
  #s.xcconfig = { "USER_HEADER_SEARCH_PATHS" => "$(SRCROOT)/smtp/curl/curl" }

end
