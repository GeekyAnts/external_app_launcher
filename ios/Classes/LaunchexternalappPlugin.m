#import "LaunchexternalappPlugin.h"





@implementation LaunchexternalappPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"launch_vpn"
            binaryMessenger:[registrar messenger]];
  LaunchexternalappPlugin* instance = [[LaunchexternalappPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } 
  else if ([@"isAppInstalled" isEqualToString:call.method]) {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:call.arguments[@"package_name"]]])
    result(@(TRUE));
    else
    result(@(FALSE));

  } else if ([@"openApp" isEqualToString:call.method]) {
    NSString *package_name;
    package_name = call.arguments[@"package_name"];
     if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:call.arguments[@"package_name"]]])
      {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call.arguments[@"package_name"]]];
        result(@(TRUE));
      }
    else 
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/in/app/appname/id404249815?mt=8"]];
   // Url Scheme of Salesforce app. To be replaced with the actual app url which redirects to AppStore.

  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
