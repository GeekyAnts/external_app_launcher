package com.example.launchexternalapp;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.content.pm.PackageManager;

/** LaunchExternalAppPlugin */
public class LaunchexternalappPlugin implements MethodCallHandler {

  private final Context context;

  private LaunchexternalappPlugin(Context context) {
    this.context = context;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "launch_vpn");
    channel.setMethodCallHandler(new LaunchexternalappPlugin(registrar.activeContext()));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("isAppInstalled")) {
      if (!call.hasArgument("package_name") || TextUtils.isEmpty(call.argument("package_name").toString())) {
        result.error("ERROR", "Empty or null package name", null);
      } else {
        String packageName = call.argument("package_name").toString();
        result.success(isAppInstalled(packageName));
      }
    } else if (call.method.equals("openApp")) {

      String packageName = call.argument("package_name");

      result.success(openApp(packageName, call.argument("open_store").toString()));

    } else {
      result.notImplemented();
    }
  }

  private boolean isAppInstalled(String packageName) {
    try {
      context.getPackageManager().getPackageInfo(packageName, 0);
      return true;
    } catch (PackageManager.NameNotFoundException ignored) {
      return false;
    }
  }

  private String openApp(String packageName, String openStore) {
    if (isAppInstalled(packageName)) {
      Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);
      if (launchIntent != null) {
        // null pointer check in case package name was not found
        context.startActivity(launchIntent);
        return "app_opened";
      }
    } else {
      if (openStore != "false") {
        Intent intent1 = new Intent(Intent.ACTION_VIEW);
        intent1.setData(android.net.Uri.parse("https://play.google.com/store/apps/details?id=" + packageName));
        context.startActivity(intent1);
        return "navigated_to_store";
      }
    }
    return "something went wrong";
  }
}
