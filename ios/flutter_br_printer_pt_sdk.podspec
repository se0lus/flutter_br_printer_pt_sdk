#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_br_printer_pt_sdk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_br_printer_pt_sdk'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin support for Brother PT-P750w'
  s.description      = <<-DESC
A flutter wrapper for brother label printer sdk.
currently only tested on PT-P750w.
                       DESC
  s.homepage         = 'http://https://github.com/se0lus/flutter_br_printer_pt_sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'se0lus' => 'at.aeolus@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.vendored_frameworks  = 'Frameworks/BRPtouchPrinterKit.framework'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
