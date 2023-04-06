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
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:call.arguments[@"package_name"]]]){
        result(@(YES));
    } else{
        result(@(NO));
    }
  } else if ([@"openApp" isEqualToString:call.method]) {
    @try {
      if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:call.arguments[@"package_name"]]]) {
        // Create a dictionary with your data to be passed to the launched app
        NSDictionary *dictionary = @{@"key": call.arguments[@"value"]};
        // Convert the dictionary to NSData
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
        // Create an options dictionary with the data to be passed to the launched app
        NSDictionary *options = @{UIApplicationLaunchOptionsURLKey: [NSURL URLWithString:call.arguments[@"package_name"]], UIApplicationLaunchOptionsAnnotationKey: data};
        // Launch the app with the options dictionary
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call.arguments[@"package_name"]] options:options completionHandler:nil];
        result(@("app_opened"));
      } else {

        NSLog(@"Is reaching here1");
        if(![@"false" isEqualToString: call.arguments[@"open_store"]]) {
          NSLog(@"Is reaching here2 %@", call.arguments[@"app_store_link"]);

          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call.arguments[@"app_store_link"]]];
          result(@("navigated_to_store"));
        }
        result(@("App not found in the device"));
      }
    }
    @catch (NSException * e) {
      NSLog(@"exception here");
      result(e);

    }
  } else {
    result(FlutterMethodNotImplemented);
  }

}

@end

