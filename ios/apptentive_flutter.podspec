Pod::Spec.new do |s|
  s.name             = 'apptentive_flutter'
  s.version          = '5.7.1-rc.6'
  s.summary          = 'Apptentive SDK for Flutter'
  s.description      = <<-DESC
Apptentive SDK for Flutter
                       DESC
  s.homepage         = 'https://github.com/apptentive/apptentive-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Apptentive' => 'sdks@apptentive.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'apptentive-ios'
  s.platform = :ios, '10.3'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
