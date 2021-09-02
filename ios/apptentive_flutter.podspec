#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint apptentive_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'apptentive_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Apptentive SDK for Flutter'
  s.description      = <<-DESC
Apptentive SDK for Flutter
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'apptentive-ios'
  s.platform = :ios, '10.3'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
