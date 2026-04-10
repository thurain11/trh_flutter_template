
const factoryBuilderTemplate = '''
final objectFactories = <Type, Function>{};
''';

const typeDefTemplate = '''
import 'package:flutter/widgets.dart';

import '../../core/network/basenetwork.dart';
import '../../core/models/response_ob.dart';

typedef Widget MainWidget(dynamic data, RefreshLoad reload);
typedef Widget More(dynamic data, RefreshLoad reload);
typedef Widget HeaderWidget();
typedef Widget FooterWidget(RefreshLoad reload);
typedef void SuccessCallback(ResponseOb resp);
typedef void CustomMoreCallback(ResponseOb resp);
typedef void CustomErrorCallback(ResponseOb resp);

typedef void RefreshLoad(
    {Map<String, dynamic>? map,
    ReqType? requestType,
    bool? refreshShowLoading});
''';

const appConstantTemplate = '''
const MAIN_WEB_URL = "https://example.com/";
const MAIN_URL = MAIN_WEB_URL + "api/";
''';

const sharedPrefTemplate = '''
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static const token = "token";
  static const language = "language";
  static const user_agent = "user_agent";
  static const shop_city = "shop_city";
  static const theme = "theme";

  static Future<void> setData({required String key, dynamic value}) async {
    final pref = await SharedPreferences.getInstance();
    if (value is String) {
      await pref.setString(key, value);
    } else if (value is int) {
      await pref.setInt(key, value);
    } else if (value is double) {
      await pref.setDouble(key, value);
    } else if (value is bool) {
      await pref.setBool(key, value);
    } else if (value is List<String>) {
      await pref.setStringList(key, value);
    } else if (value == null) {
      await pref.remove(key);
    } else {
      await pref.setString(key, value.toString());
    }
  }

  static Future<String> getData({required String key}) async {
    final pref = await SharedPreferences.getInstance();
    return pref.get(key).toString();
  }

  static Future<void> setString(
      {required String key, required String value}) async {
    await setData(key: key, value: value);
  }

  static Future<String> getString({required String key}) async {
    return getData(key: key);
  }

  static Future<void> clearData({required String key}) async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(key);
  }
}
''';

const routesTemplate = '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const Scaffold(
            body: Center(child: Text('Home')),
          );
        },
      ),
    ],
  );
}
''';

const serviceLocatorTemplate = '''
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register your services, repositories, and use cases here.
  // Example:
  // sl.registerLazySingleton<AuthService>(() => AuthService());
}
''';

const appThemeTemplate = '''
import 'package:flutter/material.dart';

class BuildThemeData {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      scaffoldBackgroundColor: Colors.white,
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }
}
''';

const appUtilTemplate = '''
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

import '../network/basenetwork.dart';
import '../models/response_ob.dart';

enum SnackColor { Warning, Success, Error }

class ToastHelper {
  static void showSuccessToast(
      {String? title, String? description, required BuildContext context}) {
    Toastification().show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        // title: Text(title??''),
        description: description != null ? Text(description) : null,
        autoCloseDuration: const Duration(seconds: 5),
        alignment: Alignment.topRight,
        animationDuration: const Duration(milliseconds: 300),
        icon: const Icon(Icons.check),
        showIcon: true,
        primaryColor: Colors.white,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: true,
        pauseOnHover: true,
        dragToClose: true,
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 16,
            offset: Offset(0, 16),
            spreadRadius: 0,
          )
        ],
        callbacks: ToastificationCallbacks(
          onTap: (toastItem) => print('Toast \${toastItem.id} tapped'),
          onDismissed: (toastItem) =>
              print('Toast \${toastItem.id} dismissed'),
        ),
        progressBarTheme: ProgressIndicatorThemeData(color: Colors.grey));
  }

  static void showErrorToast(
      {String? title, String? description, required BuildContext context}) {
    Toastification().show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,

        // title: Text(title??''),
        description: description != null ? Text(description) : null,
        backgroundColor: Colors.redAccent[200],
        primaryColor: Colors.white,
        foregroundColor: Colors.white,
        showProgressBar: true,
        autoCloseDuration: const Duration(seconds: 5),
        alignment: Alignment.topRight,
        animationDuration: const Duration(milliseconds: 300),
        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: true,
        showIcon: true,
        progressBarTheme: ProgressIndicatorThemeData(color: Colors.grey));
  }

  static checkError(ResponseOb resp, {required BuildContext context}) {
    String error = "Unknown Error";

    if (resp.errState == ErrState.no_internet) {
      error = "No Internet connection! ";
    } else if (resp.errState == ErrState.not_found) {
      error = "Your requested data not found!";
    } else if (resp.errState == ErrState.connection_timeout) {
      error = "Connection Timeout! Try Again";
    } else if (resp.errState == ErrState.too_many_request) {
      error = "Too Many Request! Try Again Later";
    } else if (resp.errState == ErrState.validate_err) {
      var v = json.decode(resp.data);
      error = v['message'].toString();
    } else if (resp.errState == ErrState.server_error) {
      error = "Internal Server Error! Try Again";
    } else if (resp.errState == ErrState.unknown_err) {
      error = "Unknown Error";
    } else {
      error = "Unknown Error";
    }

    // AppUtils.showSnackBar(error, color: Colors.red, textColor: Colors.white);
    ToastHelper.showErrorToast(description: error, context: context);
  }
}

class AppUtils {
  static PreferredSize statusBar({Color color = Colors.teal}) {
    return PreferredSize(
        child: Container(
          color: color,
        ),
        preferredSize: Size(double.infinity, 0));
  }

  // it's from notification or not
  static bool isOpenByNotification = false;

  static PreferredSize MyAppBar(
      {Widget? leading,
      required BuildContext? context,
      List<Widget>? actions,
      required String? title,
      bool centerTitle = true,
      bool autoImplement = true,
      bool hasBottomBar = false,
      PreferredSizeWidget? bottom,
      Color? color,
      Color? statusBarColor,
      Brightness? statusBrightness,
      Brightness? statusIconBrightness, // ✅ အသစ်ထည့်မယ်
      String fontFamily = 'roboto',
      double fontSize = 17,
      FontWeight fontWeight = FontWeight.w500,
      Color? textColor,
      Color? iconColor,
      Widget? widget}) {
    // Ensure context is not null
    assert(context != null, 'Context must not be null');

    final theme = Theme.of(context!);
    final appBarTheme = theme.appBarTheme;

    return PreferredSize(
      preferredSize: Size(double.infinity, (bottom == null ? 50 : 100)),
      child: AppBar(
        surfaceTintColor: Colors.transparent,
        actionsIconTheme: IconThemeData(
          color: appBarTheme.actionsIconTheme?.color ?? theme.primaryColor,
        ),
        backgroundColor: color ??
            appBarTheme.backgroundColor ??
            theme.scaffoldBackgroundColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: statusBarColor ??
              appBarTheme.backgroundColor ??
              theme.primaryColor,
          statusBarIconBrightness:
              statusIconBrightness ?? Brightness.dark, // ✅ ဒီမှာ ပြောင်း
          statusBarBrightness: statusBrightness ?? Brightness.light,
        ),
        iconTheme: IconThemeData(
          color: iconColor ?? appBarTheme.iconTheme?.color ?? theme.iconTheme.color,
        ),
        automaticallyImplyLeading: autoImplement,
        title: widget ??
            Text(
              title!,
              style: TextStyle(
                color: textColor ??
                    theme.primaryColor ??
                    theme.textTheme.headlineSmall?.color,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
        centerTitle: centerTitle,
        actions: actions,
        leading: leading,
        bottom: bottom,
      ),
    );
  }
}
''';

const themeProviderTemplate = '''
import 'package:flutter/material.dart';

import '../database/share_pref.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  checkTheme() {
    SharedPref.getString(key: SharedPref.theme).then((value) {
      if (value != "null") {
        if (value == "light") {
          themeMode = ThemeMode.light;
          notifyListeners();
        } else if (value == "dark") {
          themeMode = ThemeMode.dark;
          notifyListeners();
        } else {
          themeMode = ThemeMode.system;
          notifyListeners();
        }
      }
    });
  }

  changeToDark() {
    SharedPref.setString(key: SharedPref.theme, value: "dark");

    themeMode = ThemeMode.dark;
    notifyListeners();
  }

  changeToLight() {
    SharedPref.setString(key: SharedPref.theme, value: "light");

    themeMode = ThemeMode.light;

    notifyListeners();
  }

  changeToSystem() {
    SharedPref.setString(key: SharedPref.theme, value: "system");

    themeMode = ThemeMode.system;

    notifyListeners();
  }
}
''';

const contextExtTemplate = '''
import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  Future<T?> to<T extends Object>(Widget widget,
      {bool fullscreenDialog = false}) async {
    return await Navigator.of(this).push<T>(MaterialPageRoute(
        builder: (BuildContext context) {
          return widget;
        },
        fullscreenDialog: fullscreenDialog));
  }

  void back<T extends Object>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  Future<T?> offAll<T extends Object>(Widget widget) async {
    return await Navigator.of(this).pushAndRemoveUntil<T>(
        MaterialPageRoute(builder: (BuildContext context) {
      return widget;
    }), (route) => false);
  }

  Future<T?> off<T extends Object, TO extends Object>(Widget widget) async {
    return await Navigator.of(this)
        .pushReplacement<T, TO>(MaterialPageRoute(builder: (BuildContext context) {
      return widget;
    }));
  }

  double get height => MediaQuery.of(this).size.height;

  double get width => MediaQuery.of(this).size.width;

  Size get size => MediaQuery.of(this).size;

  // String toTrans(String txt) => AppTranslations.of(this)!.trans(txt);
}
''';
