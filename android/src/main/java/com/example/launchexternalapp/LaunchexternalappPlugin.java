package com.example.launchexternalapp;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;
import android.app.Activity;
import android.os.Bundle;
import android.content.pm.PackageManager;

import java.util.Map;


/** LaunchExternalAppPlugin */
public class LaunchexternalappPlugin implements MethodCallHandler, FlutterPlugin {

  private static MethodChannel channel;
  private Context context;

  public LaunchexternalappPlugin() {

  }
  private LaunchexternalappPlugin(Context context) {
    this.context = context;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    channel = new MethodChannel(registrar.messenger(), "launch_vpn");
    channel.setMethodCallHandler(new LaunchexternalappPlugin(registrar.activeContext()));
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "launch_vpn");
    channel.setMethodCallHandler(new LaunchexternalappPlugin(flutterPluginBinding.getApplicationContext()));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
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
      Map<String, String> data = call.argument("data");
      result.success(openApp(packageName, openStore, data));
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

private String openApp(String packageName, String openStore, Map<String, String> data) {
  if (isAppInstalled(packageName)) {
    Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);
    if (launchIntent != null) {
      // null pointer check in case package name was not found
      if (data != null) {
        for (String key : data.keySet()) {
          launchIntent.putExtra(key, data.get(key));
          Log.d("Data Passed", key + ": " + data.get(key));
        }
      }
      launchIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

      // Retrieve data passed to the app when it was launched
      Bundle extras = launchIntent.getExtras();
      if (extras != null && extras.size() > 0) {
        for (String key : extras.keySet()) {
          // Recives the data second app using getString()
          String value = extras.getString(key);
          Log.d("Data Received", key + ": " + value);
        }
      }
      context.startActivity(launchIntent);
      return "app_opened";
    }
  } else {
    if (openStore != "false") {
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
