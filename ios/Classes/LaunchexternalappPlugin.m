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
  } else if ([@"isAppInstalled" isEqualToString:call.method]) {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:call.arguments[@"package_name"]]]) {
        result(@(YES));
    } else {
        result(@(NO));
    }
    
  } else if ([@"openApp" isEqualToString:call.method]) {
    @try {
        NSURL *url = [NSURL URLWithString:call.arguments[@"package_name"]];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    result(@("app_opened"));
                } else {
                    result(@("Failed to open app"));
                }
            }];
        } else {
            NSLog(@"Is reaching here1");
            if(![@"false" isEqualToString: call.arguments[@"open_store"]]) {
                NSLog(@"Is reaching here2 %@", call.arguments[@"app_store_link"]);
                
                NSURL *storeUrl = [NSURL URLWithString:call.arguments[@"app_store_link"]];
                [[UIApplication sharedApplication] openURL:storeUrl options:@{} completionHandler:^(BOOL success) {
                    if (success) {
                        result(@("navigated_to_store"));
                    } else {
                        result(@("Failed to navigate to store"));
                    }
                }];
            } else {
                result(@("App not found on the device"));
            }
        }
    } @catch (NSException *e) {
        NSLog(@"exception here");
        result(e);
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
