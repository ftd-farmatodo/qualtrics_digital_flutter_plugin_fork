//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<integration_test/IntegrationTestPlugin.h>)
#import <integration_test/IntegrationTestPlugin.h>
#else
@import integration_test;
#endif

#if __has_include(<qualtrics_digital_flutter_plugin/QualtricsDigitalFlutterPlugin.h>)
#import <qualtrics_digital_flutter_plugin/QualtricsDigitalFlutterPlugin.h>
#else
@import qualtrics_digital_flutter_plugin;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [IntegrationTestPlugin registerWithRegistrar:[registry registrarForPlugin:@"IntegrationTestPlugin"]];
  [QualtricsDigitalFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"QualtricsDigitalFlutterPlugin"]];
}

@end
