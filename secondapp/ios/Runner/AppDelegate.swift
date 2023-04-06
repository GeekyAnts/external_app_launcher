import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    let CHANNEL = "com.example.secondapp/platform"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let flutterViewController = window?.rootViewController as! FlutterViewController
        
        let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: flutterViewController.binaryMessenger)
        
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            
            guard call.method == "getInitialIntent" else {
                result(FlutterMethodNotImplemented)
                return
            }
            
            let data = self?.handleIntent(intent: launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable : Any])
            result(data)
        }
        
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let data = handleIntent(intent: userActivity.userInfo)
        
        if let flutterViewController = window?.rootViewController as? FlutterViewController {
            
            let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: flutterViewController.binaryMessenger)
            
            channel.invokeMethod("onNewIntent", arguments: data)
        }
        
        return true
    }
    
    private func handleIntent(intent: [AnyHashable : Any]?) -> String? {
        if let data = intent?["data"] as? String {
            print("Received data: \(data)")
            return data
        }
        return nil
    }
}