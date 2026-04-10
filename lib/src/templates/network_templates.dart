
const baseNetworkTemplate = '''
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../database/share_pref.dart';
import '../models/response_ob.dart';

class DioBaseNetwork {
  // Reusable static Dio instance for the entire app
  static final Dio _dio = Dio()
    ..interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
      enabled: true,
    ));

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
    
    _dio.options.headers = await getHeader();

    if (isCached == true) {
      // _dio.interceptors.add(DioCacheManager(CacheConfig(baseUrl: url,)).interceptor);
    }

    try {
      Response response;
      if (rt == ReqType.Get) {
        if (params == null) {
          response = await _dio.get(url);
        } else {
          response = await _dio.get(
            url,
            queryParameters: params,
          );
        }
      } else if (rt == ReqType.Put) {
        if (params == null && fd == null) {
          response = await _dio.put(url);
        } else {
          response = await _dio.put(url, data: fd ?? params);
        }
      } else if (rt == ReqType.Patch) {
        if (params == null) {
          response = await _dio.patch(url);
        } else {
          response = await _dio.patch(url, queryParameters: params);
        }
      } else if (rt == ReqType.Delete) {
        if (params == null) {
          response = await _dio.delete(url);
        } else {
          response = await _dio.delete(url, queryParameters: params);
        }
      } else {
        if (params != null || fd != null) {
          response = await _dio.post(url, data: fd ?? params);
        } else {
          response = await _dio.post(url);
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
    
    _dio.options.headers = await getHeader();

    // (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
    //   client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    //   return client;
    // };

    try {
      Response response;
      response = await _dio.post(url, data: fd ?? params,
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

const pinObTemplate = '''
import 'package:flutter/foundation.dart';

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

  PnObClass.fromJson(Map<String, dynamic> json, {T Function(dynamic)? fromJson}) {
    if (json['data'] != null) {
      data = <T>[];
      json['data'].forEach((v) {
        debugPrint("Hi Hi \${v.runtimeType} \\n \$v");
        if (fromJson != null) {
          data!.add(fromJson(v));
        } else {
          data!.add(v as T);
        }
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
