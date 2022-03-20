#import "FlutterView3dPlugin.h"
#if __has_include(<flutter_view3d/flutter_view3d-Swift.h>)
#import <flutter_view3d/flutter_view3d-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_view3d-Swift.h"
#endif

@implementation FlutterView3dPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterView3dPlugin registerWithRegistrar:registrar];
}
@end
