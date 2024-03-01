#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint qualtrics_digital_flutter_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'qualtrics_digital_flutter_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Plugin for accessing the qualtrics sdk'
  s.description      = <<-DESC
Flutter plugin project for Qualtrics Website/App Feedback.
                       DESC
  s.homepage         = 'http://api.qualtrics.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Qualtrics' => 'siengineers@qualtrics.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Qualtrics'
  s.platform = :ios, '11.0'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386, arm64' }
  s.swift_version = '5.0'
  s.preserve_paths = 'Qualtrics.xcframework', 'Qualtrics.framework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework Qualtrics' }
  s.vendored_frameworks = 'Qualtrics.xcframework', 'Qualtrics.framework'
end
