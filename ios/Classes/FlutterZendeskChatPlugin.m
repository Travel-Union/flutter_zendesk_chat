#import "FlutterZendeskChatPlugin.h"
#if __has_include(<flutter_zendesk_chat/flutter_zendesk_chat-Swift.h>)
#import <flutter_zendesk_chat/flutter_zendesk_chat-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_zendesk_chat-Swift.h"
#endif

@implementation FlutterZendeskChatPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterZendeskChatPlugin registerWithRegistrar:registrar];
}
@end
