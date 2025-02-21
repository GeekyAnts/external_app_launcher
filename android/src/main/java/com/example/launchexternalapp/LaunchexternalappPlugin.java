package com.example.launchexternalapp;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.content.pm.PackageManager;

/** LaunchExternalAppPlugin */
public class LaunchexternalappPlugin implements MethodCallHandler, FlutterPlugin {

  private MethodChannel channel;
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "launch_vpn");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
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
      String openStore = call.argument("open_store").toString();
      result.success(openApp(packageName, openStore));
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
        launchIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(launchIntent);
        return "app_opened";
      }
    } else {
      if (!"false".equals(openStore)) {
        Intent intent1 = new Intent(Intent.ACTION_VIEW);
        intent1.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent1.setData(android.net.Uri.parse("https://play.google.com/store/apps/details?id=" + packageName));
        context.startActivity(intent1);
        return "navigated_to_store";
      }
    }
    return "something went wrong";
  }
}
