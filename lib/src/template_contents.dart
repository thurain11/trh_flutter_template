// Template contents for generated files.

const factoryBuilderTemplate = '''
final objectFactories = <Type, Function>{};
''';

const typeDefTemplate = '''
import 'package:flutter/widgets.dart';

import '../../core/network/basenetwork.dart';
import '../../core/ob/response_ob.dart';

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

  static Future<void> clearData({required String key}) async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(key);
  }
}
''';

const baseNetworkTemplate = '''
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/app_constant.dart';
import '../database/share_pref.dart';
import '../ob/response_ob.dart';

class DioBaseNetwork {
  Future<Map<String, String?>> getHeader() async {
    String os = "";

    if (Platform.isIOS) {
      os = "ios";
    } else if (Platform.isAndroid) {
      os = "android";
    }

    String ss = await SharedPref.getData(key: SharedPref.language);
    if (ss == "null") {
      ss = "en";
    } else if (ss == "en") {
      ss = 'en';
    } else if (ss == "mm") {
      ss = 'mm';
    }

    return {
      // "customer-destination-id": await SharedPref.getData(key: SharedPref.shop_city),
      "Authorization": await SharedPref.getData(key: SharedPref.token) ?? '',
      "Accept": "application/json",
      "language": ss,
      // "version-ios": NOW_VERSION_IOS,
      // "version-android": NOW_VERSION_ANDROID,
      // "operating-system": os,
      // "gen-ios": GEN_NUMBER_IOS,
      // "gen-android": GEN_NUMBER_ANDROID,
      "User-Agent": await SharedPref.getData(key: SharedPref.user_agent),
    };
  }

  // Dio _client;

  // Dio get client => _client;

  void getReq(String url,
      {Map<String, dynamic>? params,
      required callBackFunction callBack}) async {
    dioReq(ReqType.Get, url: url, params: params, callBack: callBack);
  }

  // Post
  void postReq(String url,
      {Map<String, dynamic>? map,
      FormData? fd,
      required callBackFunction callBack}) async {
    dioReq(ReqType.Post, url: url, params: map, fd: fd, callBack: callBack);
  }

  Future<void> dioReq(ReqType? rt,
      {required String url,
      Map<String, dynamic>? params,
      FormData? fd,
      required callBackFunction callBack,
      bool? isCached = false}) async {
    BaseOptions options = BaseOptions();
    options.headers = await getHeader();

    Dio dio = new Dio(options);

    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
      enabled: true,
    ));

    // dio.interceptors.add(LogInterceptor(
    //     responseBody: true, requestBody: true, requestHeader: true, responseHeader: true));

    if (isCached == true) {
      // dio.interceptors.add(DioCacheManager(CacheConfig(baseUrl: url,)).interceptor);
    }

    try {
      Response response;
      if (rt == ReqType.Get) {
        if (params == null) {
          response = await dio.get(url);
        } else {
          response = await dio.get(
            url,
            queryParameters: params,
          );
        }
      } else if (rt == ReqType.Put) {
        if (params == null && fd == null) {
          response = await dio.put(url);
        } else {
          response = await dio.put(url, data: fd ?? params);
        }
      } else if (rt == ReqType.Patch) {
        if (params == null) {
          response = await dio.patch(url);
        } else {
          response = await dio.patch(url, queryParameters: params);
        }
      } else if (rt == ReqType.Delete) {
        if (params == null) {
          response = await dio.delete(url);
        } else {
          response = await dio.delete(url, queryParameters: params);
        }
      } else {
        if (params != null || fd != null) {
          response = await dio.post(url, data: fd ?? params);
        } else {
          response = await dio.post(url);
        }
      }

      int? statusCode = response.statusCode;
      ResponseOb respOb = ResponseOb(); //data,message,err

      if (statusCode == 200) {
        respOb.message = MsgState.data;
        respOb.data = response.data;
      } else {
        respOb.message = MsgState.error;
        respOb.data = "Unknown error";
        respOb.errState = ErrState.unknown_err;
      }
      callBack(respOb);
    } on DioException catch (e) {
      ResponseOb respOb = new ResponseOb();

      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          respOb.message = MsgState.error;
          respOb.data = e.response.toString();
          respOb.errState = ErrState.validate_err;
        } else if (e.response!.statusCode == 500) {
          respOb.message = MsgState.error;
          respOb.data = "Internal Server Error";
          respOb.errState = ErrState.server_error;
        } else if (e.response!.statusCode == 503) {
          respOb.message = MsgState.error;
          respOb.data = "System Maintenance";
          respOb.errState = ErrState.server_maintain;
        } else if (e.response!.statusCode == 404) {
          respOb.message = MsgState.error;
          respOb.data = "Your requested data not found";
          respOb.errState = ErrState.not_found;
        } else if (e.response!.statusCode == 401) {
          respOb.message = MsgState.error;
          respOb.data = e.response!.data ?? "You need to Login";
          respOb.errState = ErrState.no_login;
        } else if (e.response!.statusCode == 429) {
          respOb.message = MsgState.error;
          respOb.data = "Too many request error";
          respOb.errState = ErrState.too_many_request;
        } else {
          if (e.toString().contains('SocketException')) {
            respOb.message = MsgState.error;
            respOb.data = "No internet connection";
            respOb.errState = ErrState.no_internet;
          } else {
            respOb.message = MsgState.error;
            respOb.data = "Unknown error";
            respOb.errState = ErrState.unknown_err;
          }
        }
      } else {
        if (e.toString().contains('SocketException')) {
          respOb.message = MsgState.error;
          respOb.data = "No internet connection";
          respOb.errState = ErrState.no_internet;
        } else {
          respOb.message = MsgState.error;
          respOb.data = "Unknown error";
          respOb.errState = ErrState.unknown_err;
        }
      }
      callBack(respOb);
    }
  }

  Future<void> dioProgressReq(
      {required String url,
      Map<String, dynamic>? params,
      FormData? fd,
      required callBackFunction callBack,
      ProgressCallbackFunction? progressCallback,
      CancelToken? cancelToken}) async {
    BaseOptions options = BaseOptions();

    options.headers = await getHeader();

    Dio dio = new Dio(options);

    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

    // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
    //   client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    //   return client;
    // };

    try {
      Response response;
      response = await dio.post(url, data: fd ?? params,
          onSendProgress: (int nowData, int totalData) {
        progressCallback!(nowData / totalData);
      }, cancelToken: cancelToken);

      int? statusCode = response.statusCode;

      ResponseOb respOb = ResponseOb(); //data,message,err

      if (statusCode == 200) {
        respOb.message = MsgState.data;
        respOb.data = response.data;
      } else {
        respOb.message = MsgState.error;
        respOb.data = "Unknown error";
        respOb.errState = ErrState.unknown_err;
      }
      callBack(respOb);
    } on DioException catch (e) {
      ResponseOb respOb = new ResponseOb();

      if (e.response != null) {
        if (e.response!.statusCode == 422) {
          respOb.message = MsgState.error;
          respOb.data = e.response.toString();
          respOb.errState = ErrState.validate_err;
        } else if (e.response!.statusCode == 500) {
          respOb.message = MsgState.error;
          respOb.data = "Internal Server Error";
          respOb.errState = ErrState.server_error;
        } else if (e.response!.statusCode == 404) {
          respOb.message = MsgState.error;
          respOb.data = "Your requested data not found";
          respOb.errState = ErrState.not_found;
        } else if (e.response!.statusCode == 401) {
          respOb.message = MsgState.error;
          respOb.data = "You need to login";
          respOb.errState = ErrState.no_login;
        } else if (e.response!.statusCode == 429) {
          respOb.message = MsgState.error;
          respOb.data = "Too many request error";
          respOb.errState = ErrState.too_many_request;
        } else {
          if (e.toString().contains('SocketException')) {
            respOb.message = MsgState.error;
            respOb.data = "No internet connection";
            respOb.errState = ErrState.no_internet;
          } else {
            respOb.message = MsgState.error;
            respOb.data = "Unknown error";
            respOb.errState = ErrState.unknown_err;
          }
        }
      } else {
        if (e.toString().contains('SocketException')) {
          respOb.message = MsgState.error;
          respOb.data = "No internet connection";
          respOb.errState = ErrState.no_internet;
        } else {
          respOb.message = MsgState.error;
          respOb.data = "Unknown error";
          respOb.errState = ErrState.unknown_err;
        }
      }
      callBack(respOb);
    }
  }
}

enum ReqType { Get, Post, Delete, Put, Patch }

typedef callBackFunction(ResponseOb ob);
typedef ProgressCallbackFunction(double i);
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

const pinObTemplate = '''
import 'package:flutter/foundation.dart';

import '../../builders/factory/factory_builder.dart';

class PnObClass<T extends Object?> {
  List<T?>? data;
  Links? links;
  Meta? meta;
  int? result;
  String? message;
  String? pageImage;

  PnObClass(
      {this.data,
      this.links,
      this.meta,
      this.result,
      this.message,
      this.pageImage});

  PnObClass.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <T>[];
      json['data'].forEach((v) {
        debugPrint("Hi Hi \${v.runtimeType} \\n \$v");
        data!.add(objectFactories[T]!(v));
      });
    }
    links = json['links'] != null ? Links.fromJson(json['links']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    result = json['result'];
    message = json['message'];
    pageImage = json['page_image'].toString();
  }
}

class Links {
  String? first;
  String? last;
  String? prev;
  String? next;

  Links({this.first, this.last, this.prev, this.next});

  Links.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    last = json['last'];
    prev = json['prev'].toString();
    next = json['next'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first'] = first;
    data['last'] = last;
    data['prev'] = prev;
    data['next'] = next;
    return data;
  }
}

class Meta {
  int? currentPage;
  int? from;
  int? lastPage;
  String? path;
  int? perPage;
  int? to;
  String? total;

  Meta(
      {this.currentPage,
      this.from,
      this.lastPage,
      this.path,
      this.perPage,
      this.to,
      this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    from = json['from'];
    lastPage = json['last_page'];
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
    total = json['total'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['path'] = path;
    data['per_page'] = perPage;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}
''';

const responseObTemplate = '''
import 'pin_ob.dart';

class ResponseOb {
  dynamic data;
  Map<String, dynamic>? map;
  MsgState? message;
  ErrState? errState;
  PageState? pgState;
  String? pageName;
  RefreshUIMode mode;
  Meta? meta;
  String? tempId;
  int? success;

  ResponseOb({
    this.data,
    this.message,
    this.pageName,
    this.pgState,
    this.errState,
    this.mode = RefreshUIMode.none,
    this.meta,
    this.map,
    this.tempId = '',
    this.success,
  });
}

enum MsgState { error, loading, data, more, server }

enum ErrState {
  no_internet,
  connection_timeout,
  not_found,
  server_error,
  too_many_request,
  unknown_err,
  validate_err,
  not_supported,
  no_login, //401
  server_maintain
}

enum PageState { first, other, no_more }

enum RefreshUIMode {
  replace,
  edit,
  delete,
  none,
  status,
  add,
  addLocalStorage,
  replaceLocalStorage,
  replaceChatInfoData,
  editLocalStorage,
  replaceEditData,
  replaceFailedData
}
''';

const appUtilTemplate = '''
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

import '../network/basenetwork.dart';
import '../ob/response_ob.dart';

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

const refreshUiBlocTemplate = '''
import 'package:rxdart/rxdart.dart';

import '../../core/constants/app_constant.dart';
import '../../core/network/basenetwork.dart';
import '../../core/ob/pin_ob.dart';
import '../../core/ob/response_ob.dart';

class RefreshUiBloc<T extends Object?> extends DioBaseNetwork {
  PublishSubject<ResponseOb> publishSubject = PublishSubject();

  Stream<ResponseOb> shopStream() => publishSubject.stream;

  String nextPageUrl = "";

  void getData(
    String url, {
    Map<String, dynamic>? map,
    ReqType? requestType = ReqType.Get,
    bool requestShowLoading = true,
    bool? isCached,
    bool isBaseUrl = true,
  }) async {
    ResponseOb resp = ResponseOb(data: null, message: MsgState.loading);
    // publishSubject.sink.add(resp);
    if (requestShowLoading) {
      publishSubject.sink.add(resp);
    }

    dioReq(
      requestType,
      url: isBaseUrl ? MAIN_URL + url : url,
      params: map,
      isCached: isCached,
      callBack: (ResponseOb rv) {
        if (rv.message == MsgState.data) {
          if (rv.data["message"].toString() == "success") {
            PnObClass<T> flv = PnObClass.fromJson(rv.data);
            nextPageUrl = flv.links!.next.toString();
            resp.message = MsgState.data;
            resp.pgState = PageState.first;
            resp.meta = flv.meta;
            resp.data = flv.data;
            publishSubject.sink.add(resp);
          } else if (rv.data['result'].toString() == "0") {
            resp.message = MsgState.more;
            resp.data = rv.data;
            publishSubject.sink.add(resp);
          } else {
            publishSubject.sink.add(rv);
          }
        } else {
          publishSubject.sink.add(rv);
        }
      },
    );
  }

  void getLoad(
    String? url,
    Map<String, dynamic>? map, {
    ReqType requestType = ReqType.Get,
    bool? isCached,
  }) async {
    ResponseOb resp = ResponseOb(data: null, message: MsgState.loading);
    if (nextPageUrl != "null" && nextPageUrl != "") {
      dioReq(
        requestType,
        url: nextPageUrl,
        params: map,
        isCached: isCached,
        callBack: (ResponseOb rv) {
          if (rv.message == MsgState.data) {
            if (rv.data["message"].toString() == "success") {
              PnObClass<T> flv = PnObClass.fromJson(rv.data);
              nextPageUrl = flv.links!.next.toString();
              resp.message = MsgState.data;
              resp.pgState = PageState.other;
              resp.data = flv.data;
              resp.meta = flv.meta;
              // resp.data = flv;
              publishSubject.sink.add(resp);
            } else if (rv.data['result'].toString() == "0") {
              resp.message = MsgState.more;
              resp.data = rv.data;
              publishSubject.sink.add(resp);
            } else {
              publishSubject.sink.add(rv);
            }
          } else {
            publishSubject.sink.add(rv);
          }
        },
      );
    } else {
      List<T> l = [];
      resp.message = MsgState.data;
      resp.data = l;
      resp.pgState = PageState.no_more;
      publishSubject.sink.add(resp);
    }
  }

  void dispose() {
    publishSubject.close();
  }
}
''';

const refreshUiBuilderTemplate = '''
import 'package:clean_archi/builders/refresh_builder/refresh_ui_bloc.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../core/network/basenetwork.dart';
import '../../core/ob/response_ob.dart';
import '../typedef/type_def.dart';

typedef Widget ChildWidget<T extends Object>(T data, RefreshLoad func, bool? isList);

typedef Widget CustomMoreWidget(Map<String, dynamic> data);

class RefreshUiBuilder<T extends Object> extends StatefulWidget {
  /// request link ရေးရန်
  String? url;

  /// request body ရေးရန်
  Map<String, dynamic>? map;

  /// listview  နဲ့ ဖော်ပြမယ်ဆိုရင် true, gridview နဲ့ ဖော်ပြမယ်ဆိုရင် false
  bool? isList;

  /// Listview ကို Sliver အနေနဲ့ သုံးချင််ရင် true
  bool isSliver;

  /// RequestType က Get ဒါမှမဟုတ် Post
  ReqType requestType;

  /// HeaderType က ယခု apex project အတွက် သီးသန့်ဖြစ်ပြီး customer, normal,agent ; default က normal

  /// ကိုယ်တိုင် loading widget ရေးချင်တဲ့အချိန်မှာ ထည့်ပေးရန် ; default က widget folder အောက်က LoadingWidget
  Widget? loadingWidget;

  /// girdView အသုံးပြုတဲ့အခါ ဖော်ပြမယ့် gridCount
  int gridCount;

  /// gridChildRatio က gridview ရဲ့ child တွေ size သတ်မှတ်ဖို့ အသုံးပြုပါတယ်
  double gridChildRatio;

  /// successResponse ကို စစ်ရန်
  SuccessCallback? successCallback;

  /// customMoreResponse
  CustomMoreCallback? customMoreCallback;

  /// errorMoreResponse
  CustomErrorCallback? customErrorCallback;

  /// listview or gridview အတွက် children widget ရေးရန်

  ChildWidget<T>? childWidget;

  Widget? scrollHeaderWidget;

  CustomMoreWidget? customMoreWidget;

  Axis scrollDirection = Axis.vertical;

  /// စာမျက်အစမှာ data ရယူချင်ရင် true, မယူချင်ရင် false,  default က true
  bool isFirstLoad;

  /// child widget ကို နှိပ်ရင် အလုပ်လုပ်မယ့် method
  // Function onChildPress;

  bool enablePullUp = false;

  ScrollController? scrollController;

  // Is Cached or not
  bool? isCached;

  //No Data Custom Widget
  Widget? noDataWidget;

  double? mainAxisExt;

  bool isNotShowSnack = false;

  double crossAxisSpacing;
  double mainAxisSpacing;

  RefreshUiBuilder.init(
      {required this.url,
      Key? key,
      this.scrollController,
      this.childWidget,
      this.isFirstLoad = true,
      this.map,
      this.scrollHeaderWidget,
      this.isList = true,
      this.requestType = ReqType.Get,
      this.loadingWidget,
      this.gridCount = 2,
      this.successCallback,
      this.customMoreCallback,
      this.customErrorCallback,
      this.gridChildRatio = 100 / 130,
      // this.onChildPress,
      this.mainAxisExt,
      this.customMoreWidget,
      this.enablePullUp = false,
      this.isCached = false,
      this.isNotShowSnack = false,
      this.noDataWidget,
      this.scrollDirection = Axis.vertical,
      this.crossAxisSpacing = 0,
      this.mainAxisSpacing = 0,
      this.isSliver = false})
      : super(key: key);

  RefreshUiBuilder(
      {required this.url,
      Key? key,
      this.scrollController,
      this.scrollDirection = Axis.vertical,
      this.childWidget,
      this.isFirstLoad = true,
      this.map,
      this.scrollHeaderWidget,
      this.isList = true,
      this.requestType = ReqType.Get,
      this.loadingWidget,
      this.gridCount = 2,
      this.successCallback,
      this.customMoreCallback,
      this.customErrorCallback,
      this.gridChildRatio = 100 / 130,
      // this.onChildPress,
      this.customMoreWidget,
      this.crossAxisSpacing = 0,
      this.mainAxisSpacing = 0,
      this.enablePullUp = false,
      this.isCached = false,
      this.noDataWidget,
      this.isNotShowSnack = false,
      this.isSliver = false})
      : super(key: key);

  @override
  RefreshUiBuilderState<T> createState() {
    return RefreshUiBuilderState<T>();
  }
}

class RefreshUiBuilderState<T> extends State<RefreshUiBuilder>
    with AutomaticKeepAliveClientMixin {
  late RefreshUiBloc<T> bloc;
  List<T> ois = [];

  late RefreshController _rController;

  PageStorageBucket bucket = PageStorageBucket();
  late PageStorageKey<String> pskey;

  @override
  void initState() {
    super.initState();
    bloc = RefreshUiBloc<T>();
    _rController = RefreshController();
    pskey = PageStorageKey<String>('refresh_\${widget.url}_\${widget.hashCode}');

    if (widget.isFirstLoad) {
      bloc.getData(widget.url!,
          map: widget.map,
          requestType: widget.requestType,
          isCached: widget.isCached);
    }

    bloc.shopStream().listen((rv) {
      if (rv.pgState != null) {
        if (rv.pgState == PageState.first) {
          _rController.refreshCompleted();
          _rController.resetNoData();
          _rController.loadComplete();
        } else {
          if (rv.message == MsgState.data) {
            if (rv.pgState == PageState.no_more) {
              _rController.loadNoData();
            } else {
              _rController.loadComplete();
            }
          }
        }
      }
      if (rv.message == MsgState.data) {
        if (widget.successCallback != null) {
          widget.successCallback!(rv);
        }
      }
      if (rv.message == MsgState.error) {
        if (widget.customErrorCallback != null) {
          widget.customErrorCallback!(rv);
        }
      }
      if (rv.message == MsgState.more) {
        if (widget.customMoreCallback != null) {
          widget.customMoreCallback!(rv);
        } else if (!widget.isNotShowSnack) {
          if (rv.data is Map<String, dynamic>) {
            Map<String, dynamic> map = rv.data as Map<String, dynamic>;
            ToastHelper.showSuccessToast(
                title: map['message'].toString(), context: context);
          }
        }
      }
    });
  }

  final pullUpSty = TextStyle(fontSize: 15, color: Colors.grey.shade400);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;
    return shopWidget(size);
  }

  func(
      {Map<String, dynamic>? map,
      ReqType? requestType = ReqType.Get,
      String? newUrl,
      bool? refreshShowLoading = true}) {
    widget.map = map;
    if (widget.isFirstLoad == false) {
      setState(() {
        widget.isFirstLoad = true;
      });
    }

    bloc.getData(newUrl == null ? widget.url! : newUrl,
        map: map,
        requestType: requestType,
        requestShowLoading: refreshShowLoading!,
        isCached: widget.isCached);
  }

  Widget shopWidget(Size size) {
    return Column(
      children: [
        !widget.isFirstLoad
            ? Container()
            : Expanded(
                child: StreamBuilder<ResponseOb>(
                    stream: bloc.shopStream(),
                    initialData:
                        ResponseOb(data: null, message: MsgState.loading),
                    builder: (context, AsyncSnapshot<ResponseOb> snap) {
                      ResponseOb rv = snap.data!;
                      if (rv.message == MsgState.loading) {
                        return widget.loadingWidget != null
                            ? widget.loadingWidget!
                            : Center(
                                child: LoadingWidget(),
                              );
                      } else if (rv.message == MsgState.data) {
                        if (rv.pgState == PageState.first) {
                          ois = rv.data;
                        } else {
                          ois.addAll(rv.data);
                        }

                        return SmartRefresher(
                            // reverse: true,
                            physics: BouncingScrollPhysics(),
                            scrollController: widget.scrollController,
                            primary:
                                widget.scrollController == null ? true : false,
                            controller: _rController,
                            footer: CustomFooter(
                              builder: (context, loadStatus) {
                                if (loadStatus == LoadStatus.loading &&
                                    widget.scrollDirection == Axis.vertical) {
                                  return LoadingWidget(size: 30);
                                } else if (loadStatus == LoadStatus.failed) {
                                  return Center(
                                      child:
                                          Text("Load fail!", style: pullUpSty));
                                } else if (loadStatus ==
                                    LoadStatus.canLoading) {
                                  return Center(
                                      child: Text('Release to load more',
                                          style: pullUpSty));
                                } else if (loadStatus == LoadStatus.idle) {
                                  return Center(
                                      child: Text('Pull up to load',
                                          style: pullUpSty));
                                } else {
                                  if (widget.scrollDirection == Axis.vertical) {
                                    return Center(
                                        child: Text('No more data',
                                            style: pullUpSty));
                                  }
                                  return Container();
                                }
                              },
                            ),
                            enablePullUp: widget.enablePullUp ? true : false,
                            // enablePullUp: true,
                            onRefresh: () {
                              bloc.getData(widget.url!,
                                  map: widget.map,
                                  requestType: widget.requestType,
                                  isCached: widget.isCached);
                            },
                            onLoading: () {
                              bloc.getLoad(widget.url, widget.map,
                                  requestType: widget.requestType,
                                  isCached: widget.isCached);
                            },
                            child: ois.length == 0
                                ? widget.noDataWidget == null
                                    ? ListView(
                                        children: <Widget>[
                                          SizedBox(
                                            height: size.height * 0.20,
                                          ),
                                          Container(
                                            child: Lottie.asset(
                                                'assets/anim/empty_data.json'),
                                            width: 170,
                                            height: 170,
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          Text(
                                            tr("no_data"),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Center(child: widget.noDataWidget)
                                : widget.scrollHeaderWidget == null
                                    ? widget.isSliver
                                        ? sliverWidget(ois)
                                        : mainList(ois)
                                    : SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            widget.scrollHeaderWidget!,
                                            mainList(ois)
                                          ],
                                        ),
                                      )
                            // mainList(ois)
                            );
                      } else if (rv.message == MsgState.error) {
                        return SingleChildScrollView(
                          child: ErrWidget(
                            rv.errState,
                            () {
                              bloc.getData(
                                widget.url!,
                                map: widget.map,
                                requestType: widget.requestType,
                              );
                            },
                          ),
                        );
                      } else if (rv.message == MsgState.more) {
                        return widget.customMoreWidget == null
                            ? MoreWidget(rv.data)
                            : widget.customMoreWidget!(rv.data);
                      } else {
                        return UnknownErrWidget(
                          fun: () {
                            bloc.getData(
                              widget.url!,
                              map: widget.map,
                              requestType: widget.requestType,
                            );
                          },
                        );
                      }
                    }),
              ),
      ],
    );
  }

  Widget mainList(List<T>? ois) {
    return widget.isList!
        ? ListView.builder(
            key: pskey,
            scrollDirection: widget.scrollDirection,
            shrinkWrap: widget.scrollHeaderWidget != null ? true : false,
            physics: widget.scrollHeaderWidget != null
                ? BouncingScrollPhysics()
                : null,
            itemBuilder: (context, index) {
              T data = ois[index];

              return widget.childWidget!(data!, func, widget.isList);
            },
            itemCount: ois!.length,
          )
        : GridView.builder(
            shrinkWrap: widget.scrollHeaderWidget != null ? true : false,
            physics: widget.scrollHeaderWidget != null
                ? BouncingScrollPhysics()
                : null,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: widget.crossAxisSpacing,
                mainAxisSpacing: widget.mainAxisSpacing,

                // mainAxisExtent: widget.mainAxisExt == null ? MediaQuery.of(context).size.width/1.6: widget.mainAxisExt,
                crossAxisCount: widget.gridCount,
                childAspectRatio: widget.gridChildRatio),
            itemBuilder: (context, index) {
              return widget.childWidget!(ois[index]!, func, widget.isList);
              // return widgetFactories[T](ois[index], () {
              //   return bloc.getData(widget.url, map: widget.map, requestType: widget.requestType, headerType: widget.headerType);
              // }, widget.onChildPress, widget.isList, index:index);
            },
            itemCount: ois!.length,
          );
  }

  Widget sliverWidget(List<T>? ois) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              T data = ois[index];
              return widget.childWidget!(data!, func, widget.isList);
            },
            childCount: ois!.length,
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _rController.dispose();
    bloc.dispose();
    super.dispose();
  }
}
''';

const singleUiBlocTemplate = '''
import 'package:rxdart/rxdart.dart';

import '../../core/constants/app_constant.dart';
import '../../core/network/basenetwork.dart';
import '../../core/ob/response_ob.dart';
import '../factory/factory_builder.dart';

class SingleUiBloc<T> extends DioBaseNetwork {
  String url;
  bool isBaseUrl;
  SingleUiBloc(this.url, {this.isBaseUrl = true});
  PublishSubject<ResponseOb> publishSubject = PublishSubject();
  Stream<ResponseOb> shopStream() => publishSubject.stream;

  void getData(
      {Map<String, dynamic>? map,
      ReqType? requestType = ReqType.Get,
      bool requestShowLoading = true,
      bool? isCached}) async {
    ResponseOb resp = ResponseOb(data: null, message: MsgState.loading);
    if (requestShowLoading) {
      publishSubject.sink.add(resp);
    }

    dioReq(requestType,
        url: isBaseUrl ? MAIN_URL + url : url,
        params: map,
        isCached: isCached, callBack: (ResponseOb rv) {
      if (rv.message == MsgState.data) {
        if (rv.data["message"].toString() == "success") {
          T? ob = objectFactories[T]!(rv.data); //
          resp.message = MsgState.data;
          resp.data = ob;
          publishSubject.sink.add(resp);
        } else if (rv.data['result'].toString() == "0") {
          resp.message = MsgState.more;
          resp.data = rv.data;
          publishSubject.sink.add(resp);
        } else {
          publishSubject.sink.add(rv);
        }
      } else {
        publishSubject.sink.add(rv);
      }
    });
  }

  void dispose() {
    publishSubject.close();
  }
}
''';

const singleUiBuilderTemplate = '''
import 'package:clean_archi/builders/single_ui_builder/single_ui_bloc.dart';
import 'package:flutter/material.dart';

import '../../core/network/basenetwork.dart';
import '../../core/ob/response_ob.dart';
import '../typedef/type_def.dart';

typedef Widget MainWidget(dynamic data, RefreshLoad reload);
typedef Widget More(dynamic data, RefreshLoad reload);
typedef void RefreshLoad(
    {Map<String, dynamic>? map,
    ReqType? requestType,
    bool? refreshShowLoading});

class SingleUiBuilder<T extends Object> extends StatefulWidget {
  /// request လုပ်မယ် url
  String url;

  bool isBaseUrl;

  String urlId;

  /// data passing လုပ်မယ် data ကို map data type ဖြင့်ပို့ပေးရန်
  Map<String, dynamic>? map;

  /// RequestType.Get or RequestType.Post/ default ->Get
  ReqType requestType;

  /// Customer, Normal, Agent/ default ->Normal

  /// data ရလျှင်ပြမည့် widget
  MainWidget widget;

  Widget? errorWidget;

  /// customLoading widget
  Widget? customLoadingWidget;

  /// စာမျက်နှာအစကတည်းက data ယူမယ်/ default -> true
  bool isInitLoading;

  /// footerWidget mainWidget ရဲ့ အောက်ခြေ widget
  FooterWidget? footerWidget;

  /// headerWidget mainWidget ရဲ့ အပေါ်ပိုင်း widget
  HeaderWidget? headerWidget;

  /// successResponse ကို စစ်ရန်
  SuccessCallback? successCallback;

  /// customMoreResponse
  CustomMoreCallback? customMoreCallback;

  /// Option More Widget
  More? moreWidget;

  /// errorMoreResponse
  CustomErrorCallback? customErrorCallback;

  /// error ကို screen တွင် ပြရုံသာမက alert နဲ့ပါ ထပ်ပြချင်တယ် ဆိုရင် true ပေးပါ
  /// defaul က false
  bool isShowAlertError = false;

  // error widget size
  double? widgetSize;

  // no login error widget

  // isCached
  bool? isCached;

  SingleUiBuilder(
      {Key? key,
      required this.url,
      required this.widget,
      this.urlId = "",
      this.isBaseUrl = true,
      this.map,
      this.requestType = ReqType.Get,
      this.customLoadingWidget,
      this.isInitLoading = true,
      this.footerWidget,
      this.headerWidget,
      this.isShowAlertError = false,
      this.successCallback,
      this.customMoreCallback,
      this.moreWidget,
      this.customErrorCallback,
      this.errorWidget,
      this.widgetSize,
      this.isCached = false})
      : super(key: key);

  @override
  SingleUiBuilderState createState() => SingleUiBuilderState<T>();
}

class SingleUiBuilderState<T> extends State<SingleUiBuilder> {
  late SingleUiBloc<T> bloc;
  @override
  void initState() {
    super.initState();

    bloc =
        SingleUiBloc<T>(widget.url + widget.urlId, isBaseUrl: widget.isBaseUrl);

    bloc.getData(
        map: widget.map,
        requestType: widget.requestType,
        isCached: widget.isCached);

    bloc.shopStream().listen((rv) {
      if (rv.message == MsgState.data) {
        if (widget.successCallback != null) {
          widget.successCallback!(rv);
        }
      }
      if (rv.message == MsgState.error) {
        if (widget.customErrorCallback != null) {
          widget.customErrorCallback!(rv);
        }
      }
      if (rv.message == MsgState.more) {
        if (widget.customMoreCallback != null) {
          widget.customMoreCallback!(rv);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  func(
      {Map<String, dynamic>? map,
      ReqType? requestType = ReqType.Get,
      bool? refreshShowLoading = true}) {
    bloc.getData(
        map: map,
        requestType: requestType,
        requestShowLoading: refreshShowLoading!,
        isCached: widget.isCached);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return mainWidget(size);
  }

  Widget mainWidget(Size size) {
    return StreamBuilder<ResponseOb>(
        stream: bloc.shopStream(),
        initialData: ResponseOb(data: null, message: MsgState.loading),
        builder: (context, AsyncSnapshot<ResponseOb> snap) {
          ResponseOb rv = snap.data!;
          if (rv.message == MsgState.loading) {
            return widget.customLoadingWidget != null
                ? widget.customLoadingWidget!
                : Center(child: LoadingWidget());
          } else if (rv.message == MsgState.data) {
            T? data = rv.data as T?;
            return widget.widget(data, func);
          } else if (rv.message == MsgState.error) {
            if (widget.errorWidget == null) {
              if (rv.errState == ErrState.no_internet) {
                return NoInternetWidget(
                  fun: () {
                    bloc.getData(
                      map: widget.map,
                      requestType: widget.requestType,
                    );
                  },
                  imgSize: widget.widgetSize,
                );
              } else if (rv.errState == ErrState.not_found) {
                return Center(
                  child: NotFoundWidget(
                    widgetSize: widget.widgetSize,
                  ),
                );
              } else if (rv.errState == ErrState.connection_timeout) {
                return ConnectionTimeoutWidget(fun: () {
                  bloc.getData(
                    map: widget.map,
                    requestType: widget.requestType,
                  );
                });
              } else if (rv.errState == ErrState.too_many_request) {
                return TooManyRequestWidget(
                  fun: () {
                    bloc.getData(
                      map: widget.map,
                      requestType: widget.requestType,
                    );
                  },
                );
              } else if (rv.errState == ErrState.server_error) {
                return ServerErrWidget(
                  fun: () {
                    bloc.getData(
                      map: widget.map,
                      requestType: widget.requestType,
                    );
                  },
                  widgetSize: widget.widgetSize,
                );
              } else if (rv.errState == ErrState.server_maintain) {
                return ServerMaintenance(widgetSize: widget.widgetSize);
              } else if (rv.errState == ErrState.no_login) {
                if (rv.data is Map<String, dynamic>) {
                  return NoLoginWidget(
                    message: rv.data['hint'].toString(),
                  );
                }
                return NoLoginWidget();
              } else if (rv.errState == ErrState.unknown_err) {
                return UnknownErrWidget(
                  fun: () {
                    bloc.getData(
                      map: widget.map,
                      requestType: widget.requestType,
                    );
                  },
                  widgetSize: widget.widgetSize,
                );
              } else {
                return UnknownErrWidget(
                  fun: () {
                    bloc.getData(
                      map: widget.map,
                      requestType: widget.requestType,
                    );
                  },
                );
              }
            } else {
              return widget.errorWidget!;
            }
          } else if (rv.message == MsgState.more) {
            if (widget.moreWidget == null) {
              return Card(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // if (rv.data['warning_message'] != null && rv.data['show_refresh_btn'] == 1)
                      //  PaymentWaitingWidget<T>(,requestType: widget.requestType,bloc: bloc,map: widget.map,rv: rv,),

                      if (rv.data["target"] == "send-request")
                        Container(
                            height: 200,
                            width: 200,
                            child: Image.asset(
                              'assets/icons/denied_removebg.png',
                              fit: BoxFit.fill,
                            )),
                      if (rv.data['warning_message'] == null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              rv.data['message'].toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            ElevatedButton.icon(
                                onPressed: () {
                                  context.back();
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "Back",
                                  style: TextStyle(color: Colors.white),
                                ))
                          ],
                        ),
                      // send-request
                      if (rv.data["target"] == "send-request")
                        const SizedBox(
                          height: 10,
                        ),
                      if (rv.data["target"] == "send-request")
                        ElevatedButton(
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              textStyle: TextStyle(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            // context.offAll(StarFishPage());
                          },
                          child: Text(
                            "SEND REQUEST",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            } else {
              Map<dynamic, dynamic> moreData = rv.data as Map;
              return widget.moreWidget!(moreData, func);
            }
          } else {
            return UnknownErrWidget(
              fun: () {
                bloc.getData(
                  map: widget.map,
                  requestType: widget.requestType,
                );
              },
            );
          }
        });
  }

  checkDialog() async {
    // if (widget.isShowDialog) {
    //   isShowingDialog = true;
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Stack(
            // overflow: Overflow.visible,
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white),
                child: LoadingWidget(),
              ),
            ],
          );
        }).then((v) {
      // isShowingDialog = false;
    });
    // }
  }
}
''';

const requestButtonBlocTemplate = '''
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../core/constants/app_constant.dart';
import '../../core/network/basenetwork.dart';
import '../../core/ob/response_ob.dart';

class RequestButtonBloc extends DioBaseNetwork {
  PublishSubject<ResponseOb> requestButtonController = PublishSubject();
  Stream<ResponseOb> getRequestStream() => requestButtonController.stream;

  postData(url,
      {FormData? fd,
      Map<String, dynamic>? map,
      ReqType requestType = ReqType.Post,
      bool requestShowLoading = true,
      bool? isBaseUrl,
      String? tempId = '',}) async {
    ResponseOb resp = ResponseOb(data: null, message: MsgState.loading);
    if (requestShowLoading) {
      requestButtonController.sink.add(resp);
    }
    dioReq(requestType, url: MAIN_URL + url, params: map, fd: fd,
        callBack: (ResponseOb rv) {
      if (rv.message == MsgState.data) {
        if (rv.data["result"].toString() == "1") {
          resp.message = MsgState.data;
          resp.data = rv.data;
          resp.tempId = tempId;
          requestButtonController.sink.add(resp);
        } else if (rv.data['result'].toString() == "0") {
          resp.message = MsgState.more;
          resp.data = rv.data; //map['message'].toString();
          requestButtonController.sink.add(resp);
        } else {
          requestButtonController.sink.add(rv);
        }
      } else {
        requestButtonController.sink.add(rv);
      }
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  void disponse() {
    requestButtonController.close();
  }
}
''';
