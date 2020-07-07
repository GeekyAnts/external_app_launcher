#import "LaunchVpnPlugin.h"

@implementation LaunchVpnPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"launch_vpn"
            binaryMessenger:[registrar messenger]];
  LaunchVpnPlugin* instance = [[LaunchVpnPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"isAppInstalled" isEqualToString:call.method]) {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:call.arguments[@"package_name"]]])
      result(@(TRUE));
    else
      result(@(FALSE));
    
  } else if ([@"openApp" isEqualToString:call.method]) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call.arguments[@"package_name"]]];
    result(@(TRUE));
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
