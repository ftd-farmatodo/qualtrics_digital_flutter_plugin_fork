#import "QualtricsDigitalFlutterPlugin.h"
#if __has_include(<qualtrics_digital_flutter_plugin/qualtrics_digital_flutter_plugin-Swift.h>)
#import <qualtrics_digital_flutter_plugin/qualtrics_digital_flutter_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "qualtrics_digital_flutter_plugin-Swift.h"
#endif

@implementation QualtricsDigitalFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftQualtricsDigitalFlutterPlugin registerWithRegistrar:registrar];
}
@end
