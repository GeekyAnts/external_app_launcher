package com.example.launchexternalapp;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.text.TextUtils;
import android.net.Uri;

import androidx.annotation.NonNull;

import java.net.URISyntaxException;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * Flutter plugin entry point for opening other apps on Android.
 *
 * <p>Communicates over the {@code launch_vpn} method channel. Dart passes either a
 * plain package name (legacy path) or an {@code android_intent_uri} string for a
 * full <a href="https://developer.android.com/reference/android/content/Intent#intent-scheme">intent
 * URI</a> ({@code intent://…#Intent;…;end}). Intent URIs embed action, categories,
 * and string extras ({@code S.*}) so callers can deep-link with data without
 * building an {@link Intent} in Dart.
 *
 * <p>Return values are string tokens consumed by Dart and mapped to success (1)
 * or failure (0); keep them stable for API compatibility.
 */
public class LaunchexternalappPlugin implements FlutterPlugin, MethodCallHandler {

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
    if (context == null) {
      result.error("ERROR", "Context is null", null);
      return;
    }

    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "isAppInstalled":
        // Dart: either android_intent_uri (resolveActivity) or package_name (getPackageInfo); not both.
        String intentUri = call.argument("android_intent_uri");
        if (intentUri != null && !TextUtils.isEmpty(intentUri)) {
          result.success(isIntentResolvable(intentUri));
        } else {
          String packageName = call.argument("package_name");
          if (packageName == null || TextUtils.isEmpty(packageName)) {
            result.error("ERROR", "Empty or null package name", null);
          } else {
            result.success(isAppInstalled(packageName));
          }
        }
        break;
      case "openApp":
        String openStore = call.argument("open_store");
        String appStoreLink = call.argument("app_store_link");
        String androidIntentUri = call.argument("android_intent_uri");
        if (androidIntentUri != null && !TextUtils.isEmpty(androidIntentUri)) {
          String packageName = call.argument("package_name");
          result.success(openAppWithIntentUri(androidIntentUri, openStore, appStoreLink, packageName));
        } else {
          String packageName = call.argument("package_name");
          result.success(openApp(packageName, openStore));
        }
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  /**
   * True when {@link PackageManager#getPackageInfo(String, int)} succeeds for this
   * user/profile (i.e. the package is installed or otherwise visible to this app).
   * False when no application id matches (uninstalled, typo, or different user).
   * This does not guarantee a launchable activity exists.
   *
   * <p>{@code NameNotFoundException} is the API contract for "no such package";
   * the catch variable is named {@code ignored} because we do not inspect it and
   * only map failure to {@code false}.
   *
   * @param packageName application id (e.g. {@code com.example.app})
   */
  private boolean isAppInstalled(String packageName) {
    try {
      PackageManager pm = context.getPackageManager();
      // PackageInfoFlags was introduced in API 33; the int overload is deprecated there
      // but is the only option below it — both forms are equivalent for a flags value of 0.
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        pm.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0));
      } else {
        pm.getPackageInfo(packageName, 0);
      }
      return true;
    } catch (PackageManager.NameNotFoundException ignored) {
      return false;
    }
  }

  /**
   * Whether some activity on the device can handle the intent produced from an
   * intent-scheme URI. Malformed URIs yield {@code false} (same as unresolvable).
   */
  private boolean isIntentResolvable(String intentUriString) {
    try {
      Intent intent = Intent.parseUri(intentUriString, Intent.URI_INTENT_SCHEME);
      return intent.resolveActivity(context.getPackageManager()) != null;
    } catch (URISyntaxException e) {
      return false;
    }
  }

  /**
   * Opens the default launcher activity for {@code packageName}, or the Play
   * Store listing if the package is missing and store navigation is allowed.
   *
   * @return {@code app_opened}, {@code navigated_to_store}, or {@code something went wrong}
   */
  private String openApp(String packageName, String openStore) {
    if (isAppInstalled(packageName)) {
      Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);
      if (launchIntent != null) {
        launchIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        try {
          context.startActivity(launchIntent);
        } catch (ActivityNotFoundException | SecurityException e) {
          // isAppInstalled passed, but the app could be uninstalled in the
          // window between that check and here (TOCTOU). ActivityNotFoundException
          // is unchecked, so without this catch it would silently crash the host app.
          return "something went wrong";
        }
        return "app_opened";
      }
    } else if (!"false".equals(openStore)) {
      Intent intent1 = new Intent(Intent.ACTION_VIEW);
      intent1.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      intent1.setData(Uri.parse("https://play.google.com/store/apps/details?id=" + packageName));
      try {
        context.startActivity(intent1);
      } catch (ActivityNotFoundException | SecurityException e) {
        return "something went wrong";
      }
      return "navigated_to_store";
    }
    return "something went wrong";
  }

  /**
   * Parses an intent URI, starts the resolved activity when possible, otherwise
   * falls back in order: optional {@code appStoreLink} (VIEW), optional
   * {@code packageName} Play listing, or an error string. Used when Dart passes
   * {@code android_intent_uri}.
   *
   * @param packageName optional; used only for Play Store fallback when the intent
   *                    does not resolve (e.g. same app id as the target market listing).
   * @return {@code app_opened}, {@code navigated_to_store}, {@code App not found on the device},
   *         or {@code invalid_intent_uri} if parsing fails
   */
  private String openAppWithIntentUri(String intentUriString, String openStore, String appStoreLink, String packageName) {
    try {
      Intent intent = Intent.parseUri(intentUriString, Intent.URI_INTENT_SCHEME);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      if (intent.resolveActivity(context.getPackageManager()) != null) {
        try {
          context.startActivity(intent);
        } catch (ActivityNotFoundException | SecurityException e) {
          // Guard against the app being uninstalled between resolveActivity and here.
          return "something went wrong";
        }
        return "app_opened";
      }
      if (!"false".equals(openStore)) {
        if (appStoreLink != null && !appStoreLink.isEmpty()) {
          Intent view = new Intent(Intent.ACTION_VIEW, Uri.parse(appStoreLink));
          view.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
          try {
            context.startActivity(view);
          } catch (ActivityNotFoundException | SecurityException e) {
            return "something went wrong";
          }
          return "navigated_to_store";
        }
        if (packageName != null && !packageName.isEmpty()) {
          Intent play = new Intent(Intent.ACTION_VIEW);
          play.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
          play.setData(Uri.parse("https://play.google.com/store/apps/details?id=" + packageName));
          try {
            context.startActivity(play);
          } catch (ActivityNotFoundException | SecurityException e) {
            return "something went wrong";
          }
          return "navigated_to_store";
        }
      }
      return "App not found on the device";
    } catch (URISyntaxException e) {
      return "invalid_intent_uri";
    }
  }
}
