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
    NSURL *appURL = [NSURL URLWithString:call.arguments[@"package_name"]];
    if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
      result(@(YES));
    } else {
      result(@(NO));
    }
  } else if ([@"openApp" isEqualToString:call.method]) {
    @try {
      NSURL *appURL = [NSURL URLWithString:call.arguments[@"package_name"]];
      if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
        [[UIApplication sharedApplication] openURL:appURL
                                           options:@{}
                                 completionHandler:^(BOOL success) {
          if (success) {
            result(@"app_opened");
          } else {
            result(@"failed_to_open_app");
          }
        }];
      } else {
        if (![call.arguments[@"open_store"] isEqualToString:@"false"]) {
          NSURL *storeURL = [NSURL URLWithString:call.arguments[@"app_store_link"]];
          [[UIApplication sharedApplication] openURL:storeURL
                                             options:@{}
                                   completionHandler:^(BOOL success) {
            if (success) {
              result(@"navigated_to_store");
            } else {
              result(@"failed_to_open_store");
            }
          }];
        } else {
          result(@"App not found in the device");
        }
      }
    } @catch (NSException *e) {
      NSLog(@"Exception occurred: %@", e);
      result([FlutterError errorWithCode:@"UNAVAILABLE"
                                 message:@"Failed to open app"
                                 details:e.reason]);
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end