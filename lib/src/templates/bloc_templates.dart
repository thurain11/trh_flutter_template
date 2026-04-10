
const externalRefreshUiBlocTemplate = '''
// import 'package:rxdart/rxdart.dart';
//
// import '../../core/constants/app_constants.dart';
// import '../../core/network/dio_basenetwork.dart';
// import '../../core/models/response_ob.dart';
// import '../factory/factory_builder.dart';
// //final factories = <Type, Function>{ObClass: (int x) => ObClass.fromJson(x)};
//
// class DataRefreshUiBloc<T> extends DioBaseNetwork {
//   PublishSubject<ResponseOb> publishSubject = PublishSubject();
//   Stream<ResponseOb> shopStream() => publishSubject.stream;
//
//   int page = 1;
//
//   void getData(String url, {Map<String, dynamic>? map, ReqType? requestType = ReqType.Get, bool requestShowLoading = true}) async {
//     page = 1;
//     ResponseOb resp = ResponseOb(data: null, message: MsgState.loading);
//     if (requestShowLoading) {
//       publishSubject.sink.add(resp);
//     }
//     if (map != null) {
//       map['page'] = page;
//     } else {
//       map = {"page": page};
//     }
//
//     dioReq(requestType, url: MAIN_URL + url, params: map, callBack: (ResponseOb rv) {
//       if (rv.message == MsgState.data) {
//         if (rv.data["result"].toString() == "1") {
//           T? ob = objectFactories[T]!(rv.data);
//           resp.message = MsgState.data;
//           resp.pgState = PageState.first;
//           resp.data = ob;
//           publishSubject.sink.add(resp);
//         } else if (rv.data['result'].toString() == "0") {
//           resp.message = MsgState.more;
//           resp.data = rv.data;
//           publishSubject.sink.add(resp);
//         } else {
//           publishSubject.sink.add(rv);
//         }
//       } else {
//         publishSubject.sink.add(rv);
//       }
//     });
//   }
//
//   void getLoad(String url, {Map<String, dynamic>? map, ReqType requestType = ReqType.Get,}) async {
//     page++;
//     ResponseOb resp = ResponseOb(data: null, message: MsgState.loading);
//     if (map != null) {
//       map['page'] = page;
//     } else {
//       map = {"page": page};
//     }
//
//     dioReq(requestType, url: MAIN_URL + url, params: map, callBack: (ResponseOb rv) {
//       if (rv.message == MsgState.data) {
//         if (rv.data["result"].toString() == "1") {
//           Map<String, dynamic> map = rv.data;
//           List list = map['data'];
//           if (list.length > 0) {
//             T? ob = objectFactories[T]!(rv.data);
//             resp.message = MsgState.data;
//             resp.pgState = PageState.other;
//             resp.data = ob;
//             publishSubject.sink.add(resp);
//           } else {
//             T? ob = objectFactories[T]!(rv.data);
//             resp.message = MsgState.data;
//             resp.data = ob;
//             resp.pgState = PageState.no_more;
//             publishSubject.sink.add(resp);
//           }
//         } else if (rv.data['result'].toString() == "0") {
//           resp.message = MsgState.more;
//           resp.data = rv.data;
//           publishSubject.sink.add(resp);
//         } else {
//           publishSubject.sink.add(rv);
//         }
//       } else {
//         publishSubject.sink.add(rv);
//       }
//     });
//
//   }
//
//   void deleteData(T data) {
//     ResponseOb resp = ResponseOb(data: data, mode: RefreshUIMode.delete, message: MsgState.data);
//     publishSubject.sink.add(resp);
//   }
//
//   void replaceData(T data, int index) {
//     ResponseOb resp = ResponseOb(data: {"data": data, "index": index}, mode: RefreshUIMode.replace, message: MsgState.data);
//     publishSubject.sink.add(resp);
//   }
//
//   void dispose() {
//     publishSubject.close();
//   }
// }
''';

const externalRefreshUiBuilderTemplate = '''
// import 'package:pull_to_refresh/pull_to_refresh.dart';
//
// import '../../core/network/dio_basenetwork.dart';
// import '../../core/models/response_ob.dart';
// import '../../global.dart';
// import '../../widgets/err_state_widget/connection_timeout_widget.dart';
// import '../../widgets/err_state_widget/no_data_widget.dart';
// import '../../widgets/err_state_widget/no_internet_widget.dart';
// import '../../widgets/err_state_widget/not_found_widget.dart';
// import '../../widgets/err_state_widget/server_err_widget.dart';
// import '../../widgets/err_state_widget/too_many_request_widget.dart';
// import '../../widgets/err_state_widget/unknown_err_widget.dart';
// import '../../widgets/loading_widget.dart';
// import '../typedef/type_def.dart';
// import 'external_refresh_ui_bloc.dart';
//
// enum ChildWidgetPosition { top, bottom }
//
// class ExternalRefreshUiBuilder<T, D> extends StatefulWidget {
//   /// request link ရေးရန်
//   String url;
//
//   /// request body ရေးရန်
//   Map<String, dynamic>? map;
//
//   /// listview  နဲ့ ဖော်ပြမယ်ဆိုရင် true, gridview နဲ့ ဖော်ပြမယ်ဆိုရင် false
//   bool isList;
//
//   /// RequestType က Get ဒါမှမဟုတ် Post
//   ReqType requestType;
//
//   /// HeaderType က ယခု apex project အတွက် သီးသန့်ဖြစ်ပြီး customer, normal,agent ; default က normal
//
//   /// ကိုယ်တိုင် loading widget ရေးချင်တဲ့အချိန်မှာ ထည့်ပေးရန် ; default က widget folder အောက်က LoadingWidget
//   Widget? loadingWidget;
//
//   /// girdView အသုံးပြုတဲ့အခါ ဖော်ပြမယ့် gridCount
//   int gridCount;
//
//   Function? dataClearFunc;
//   bool isDataClear;
//
//   /// gridChildRatio က gridview ရဲ့ child တွေ size သတ်မှတ်ဖို့ အသုံးပြုပါတယ်
//   double gridChildRatio;
//
//   /// successResponse ကို စစ်ရန်
//   SuccessCallback? successCallback;
//
//   /// customMoreResponse
//   CustomMoreCallback? customMoreCallback;
//
//   /// errorMoreResponse
//   CustomErrorCallback? customErrorCallback;
//
//   ExternalRefreshWidgetbuilder? builder;
//
//   /// စာမျက်အစမှာ data ရယူချင်ရင် true, မယူချင်ရင် false,  default က true
//   bool isFirstLoad;
//
//   CommunityChildWidget? childWidget;
//
//   bool enablePullUp = false;
//   ScrollController? scrollController;
//   ScorllableHeaderWidget? scorllableHeaderWidget;
//   String? param;
//
//   ExternalRefreshUiBuilder(
//       {required this.url,
//       Key? key,
//       this.scrollController,
//       this.isFirstLoad = true,
//       this.map,
//       this.builder,
//       this.isList = true,
//       this.childWidget,
//       this.requestType = ReqType.Get,
//       this.loadingWidget,
//       this.scorllableHeaderWidget,
//       this.gridCount = 2,
//       this.successCallback,
//       this.customMoreCallback,
//       this.customErrorCallback,
//       this.gridChildRatio = 100 / 130,
//       this.enablePullUp = false,
//       this.param,
//       this.dataClearFunc,
//       this.isDataClear = false,
//       })
//       : super(key: key);
//
//   @override
//   ExternalRefreshUiBuilderState createState() => ExternalRefreshUiBuilderState<T, D>(this.map);
// }
//
// class ExternalRefreshUiBuilderState<T, D> extends State<ExternalRefreshUiBuilder> {
//   late DataRefreshUiBloc<T> bloc;
//   List<D>? ois = [];
//   late RefreshController _rController;
//   Map<String, dynamic>? map;
//   ExternalRefreshUiBuilderState(this.map);
//
//   void replace(T data, int index) {
//     bloc.replaceData(data, index);
//   }
//
//   void deleteData(T data) {
//     bloc.deleteData(data);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     bloc = DataRefreshUiBloc<T>();
//     _rController = RefreshController();
//     if (widget.isFirstLoad) {
//       bloc.getData(widget.url, map: widget.map, requestType: widget.requestType,);
//     }
//     bloc.shopStream().listen((rv) {
//       if (rv.pgState != null) {
//         if (rv.pgState == PageState.first) {
//           _rController.refreshCompleted();
//           _rController.resetNoData();
//           _rController.loadComplete();
//         } else {
//           if (rv.message == MsgState.data) {
//             if (rv.pgState == PageState.no_more) {
//               _rController.loadNoData();
//             } else {
//               _rController.loadComplete();
//             }
//           }
//         }
//       }
//       if (rv.message == MsgState.data) {
//         if (widget.successCallback != null) {
//           widget.successCallback!(rv);
//         }
//       }
//       if (rv.message == MsgState.error) {
//         if (widget.customErrorCallback != null) {
//           widget.customErrorCallback!(rv);
//         }
//       }
//       if (rv.message == MsgState.more) {
//         if (widget.customMoreCallback != null) {
//           widget.customMoreCallback!(rv);
//         }
//       }
//     });
//   }
//
//   final pullUpSty = TextStyle(fontSize: 15, color: Colors.grey.shade400);
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return shopWidget(size);
//   }
//
//   func({Map<String, dynamic>? map, ReqType? requestType = ReqType.Get, bool? refreshShowLoading = true}) {
//     this.map = map;
//     setState(() {
//       widget.isFirstLoad = true;
//     });
//     bloc.getData(widget.url,
//         map: map, requestType: requestType, requestShowLoading: refreshShowLoading!);
//   }
//
//   Widget shopWidget(Size size) {
//     return StreamBuilder<ResponseOb>(
//         stream: bloc.shopStream(),
//         initialData: ResponseOb(data: null, message: MsgState.loading),
//         builder: (context, AsyncSnapshot<ResponseOb> snap) {
//           ResponseOb rv = snap.data!;
//           if (rv.message == MsgState.loading) {
//             return widget.loadingWidget != null
//                 ? widget.loadingWidget!
//                 : Center(
//                     child: LoadingWidget(),
//                   );
//           } else if (rv.message == MsgState.data) {
//             T? ob;
//             if (rv.pgState == PageState.first) {
//               ob = rv.data;
//               ois = rv.data.data;
//             } else {
//               ob = rv.data;
//               ois!.addAll(rv.data.data);
//             }
//             return widget.builder!(
//                 SmartRefresher(
//                     physics: BouncingScrollPhysics(),
//                     scrollController: widget.scrollController,
//                     primary: widget.scrollController == null ? true : false,
//                     controller: _rController,
//                     enablePullUp: widget.enablePullUp ? widget.enablePullUp : ois!.length > 9,
//                     // enablePullUp: true,
//                     footer: CustomFooter(
//                       builder: (context, loadStatus) {
//                         if (loadStatus == LoadStatus.loading) {
//                           return LoadingWidget(size: 30);
//                         } else if (loadStatus == LoadStatus.failed) {
//                           return Center(child: Text("Load fail!", style: pullUpSty));
//                         } else if (loadStatus == LoadStatus.canLoading) {
//                           return Center(child: Text('Release to load more', style: pullUpSty));
//                         } else if (loadStatus == LoadStatus.idle) {
//                           return Center(child: Text('Pull up to load', style: pullUpSty));
//                         } else {
//                           return Container();
//                         }
//                       },
//                     ),
//                     onRefresh: () {
//                       if (widget.isDataClear) {
//                         widget.dataClearFunc!();
//                       } else {
//                         bloc.getData(widget.url, map: map, requestType: widget.requestType,);
//                       }
//                     },
//                     onLoading: () {
//                       bloc.getLoad(widget.url, map: map, requestType: widget.requestType,);
//                     },
//                     child: ois!.length == 0
//                         ? ListView(
//                             children: <Widget>[
//                               SizedBox(
//                                 height: size.height * 0.20,
//                               ),
//                               Container(
//                                 child: Image.asset('assets/anim/empty_data.json'),
//                                 width: 150,
//                                 height: 150,
//                               ),
//                               SizedBox(
//                                 height: 10.0,
//                               ),
//                               Text(
//                                 'NO DATA',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           )
//                         : widget.scorllableHeaderWidget == null
//                             ? mainList(
//                                 ois,
//                               )
//                             : ListView(
//                                 children: [
//                                   widget.scorllableHeaderWidget!(ob),
//                                   mainList(ois),
//                                 ],
//                               )),
//                 ob);
//           } else if (rv.message == MsgState.error) {
//             if (rv.errState == ErrState.no_internet) {
//               return NoInternetWidget(fun: () {
//                 bloc.getData(widget.url, map: widget.map, requestType: widget.requestType,);
//               });
//             } else if (rv.errState == ErrState.not_found) {
//               return NotFoundWidget();
//             } else if (rv.errState == ErrState.connection_timeout) {
//               return ConnectionTimeoutWidget(fun: () {
//                 bloc.getData(widget.url, map: widget.map, requestType: widget.requestType,);
//               });
//             } else if (rv.errState == ErrState.too_many_request) {
//               return TooManyRequestWidget(
//                 fun: () {
//                   bloc.getData(widget.url, map: widget.map, requestType: widget.requestType,);
//                 },
//               );
//             } else if (rv.errState == ErrState.server_error) {
//               return ServerErrWidget(fun: () {
//                 bloc.getData(widget.url, map: widget.map, requestType: widget.requestType,);
//               });
//             } else if (rv.errState == ErrState.unknown_err) {
//               return UnknownErrWidget(
//                 fun: () {
//                   bloc.getData(widget.url, map: widget.map, requestType: widget.requestType,);
//                 },
//               );
//             } else {
//               return UnknownErrWidget(
//                 fun: () {
//                   bloc.getData(widget.url, map: widget.map, requestType: widget.requestType,);
//                 },
//               );
//             }
//           } else if (rv.message == MsgState.more) {
//             return NoDataWidget();
//           } else {
//             return UnknownErrWidget(
//               fun: () {
//                 bloc.getData(widget.url, map: widget.map, requestType: widget.requestType,);
//               },
//             );
//           }
//         });
//   }
//
//   Widget mainList(List<D>? ois) {
//     return widget.isList
//         ? ListView.builder(
//             shrinkWrap: widget.scorllableHeaderWidget == null ? false : true,
//             physics: widget.scorllableHeaderWidget == null ? null : ClampingScrollPhysics(),
//             itemBuilder: (context, index) {
//               D data = ois[index];
//               return widget.childWidget!(data, func, widget.isList, index, deleteData, replace);
//               // return widgetFactories[D](ois[index], () {
//               //   return bloc.getData(widget.url, map: widget.map, requestType: widget.requestType,);
//               // }, widget.onChildPress, widget.isList, delete: deleteData, index: index, replace: replace,param:widget.param);
//             },
//             itemCount: ois!.length,
//           )
//         : GridView.builder(
//             shrinkWrap: widget.scorllableHeaderWidget == null ? false : true,
//             physics: widget.scorllableHeaderWidget == null ? null : ClampingScrollPhysics(),
//             gridDelegate:
//                 SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: widget.gridCount, childAspectRatio: widget.gridChildRatio),
//             itemBuilder: (context, index) {
//               D data = ois[index];
//               return widget.childWidget!(data, func, widget.isList, index, deleteData, replace);
//             },
//             itemCount: ois!.length,
//           );
//   }
// }
''';

const refreshUiBlocTemplate = '''
import 'package:rxdart/rxdart.dart';

import '../../core/constants/app_constant.dart';
import '../../core/network/basenetwork.dart';
import '../../core/models/pin_ob.dart';
import '../../core/models/response_ob.dart';

class RefreshUiBloc<T extends Object?> {
  final DioBaseNetwork _network = DioBaseNetwork();
  PublishSubject<ResponseOb> publishSubject = PublishSubject();

  Stream<ResponseOb> shopStream() => publishSubject.stream;

  String nextPageUrl = "";

  T Function(dynamic)? fromJson;
  RefreshUiBloc({this.fromJson});

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

    _network.dioReq(
      requestType,
      url: isBaseUrl ? MAIN_URL + url : url,
      params: map,
      isCached: isCached,
      callBack: (ResponseOb rv) {
        if (rv.message == MsgState.data) {
          if (rv.data["message"].toString() == "success") {
            PnObClass<T> flv = PnObClass.fromJson(rv.data, fromJson: fromJson);
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
      _network.dioReq(
        requestType,
        url: nextPageUrl,
        params: map,
        isCached: isCached,
        callBack: (ResponseOb rv) {
          if (rv.message == MsgState.data) {
            if (rv.data["message"].toString() == "success") {
              PnObClass<T> flv = PnObClass.fromJson(rv.data, fromJson: fromJson);
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
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../core/network/basenetwork.dart';
import '../../core/models/response_ob.dart';
import '../../core/utils/app_util.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/err_state_widget/err_widget.dart';
import '../../widgets/err_state_widget/more_widget.dart';
import '../../widgets/err_state_widget/unknown_err_widget.dart';
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
                                            "No Data",
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
import '../../core/models/response_ob.dart';

class SingleUiBloc<T> {
  final DioBaseNetwork _network = DioBaseNetwork();
  String url;
  bool isBaseUrl;
  T Function(dynamic)? fromJson;
  SingleUiBloc(this.url, {this.isBaseUrl = true, this.fromJson});
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

    _network.dioReq(requestType,
        url: isBaseUrl ? MAIN_URL + url : url,
        params: map,
        isCached: isCached, callBack: (ResponseOb rv) {
      if (rv.message == MsgState.data) {
        if (rv.data["message"].toString() == "success") {
          T? ob;
          if (fromJson != null) {
            ob = fromJson!(rv.data);
          } else {
            ob = rv.data as T?;
          }
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
import '../../core/models/response_ob.dart';
import '../../core/utils/context_ext.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/err_state_widget/connection_timeout_widget.dart';
import '../../widgets/err_state_widget/no_internet_widget.dart';
import '../../widgets/err_state_widget/no_login_widget.dart';
import '../../widgets/err_state_widget/not_found_widget.dart';
import '../../widgets/err_state_widget/server_err_widget.dart';
import '../../widgets/err_state_widget/server_maintenance_widget.dart';
import '../../widgets/err_state_widget/too_many_request_widget.dart';
import '../../widgets/err_state_widget/unknown_err_widget.dart';
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

  T Function(dynamic)? fromJson;

  SingleUiBuilder(
      {Key? key,
      required this.url,
      required this.widget,
      this.fromJson,
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
  SingleUiBuilderState<T> createState() => SingleUiBuilderState<T>();
}

class SingleUiBuilderState<T extends Object> extends State<SingleUiBuilder<T>> {
  late SingleUiBloc<T> bloc;
  @override
  void initState() {
    super.initState();

    bloc = SingleUiBloc<T>(widget.url + widget.urlId,
            isBaseUrl: widget.isBaseUrl,
            fromJson: widget.fromJson);

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
    bloc.dispose();
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
                return ServerMaintenanceWidget(widgetSize: widget.widgetSize);
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
import '../../core/models/response_ob.dart';

class RequestButtonBloc {
  final DioBaseNetwork _network = DioBaseNetwork();
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
    _network.dioReq(requestType, url: MAIN_URL + url, params: map, fd: fd,
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

const requestButtonTemplate = '''
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/basenetwork.dart';
import '../../core/models/response_ob.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_util.dart';
import '../../widgets/common/loading_widget.dart';
import 'request_button_bloc.dart';

typedef dynamic OnPressed();
typedef Future<Map<String, dynamic>?>? onAsyncPressed();

typedef void SuccessFuncMethod(ResponseOb ob);
typedef void ValidFuncMethod(ResponseOb ob);
typedef void MoreFuncMethod(ResponseOb ob);
typedef void StateFuncMethod(ResponseOb ob);

class RequestButton extends StatefulWidget {
  String? url; //request url
  String? text; //
  ScaffoldState? scaffoldState;
  bool changeFormData; //dio request -> true/false
  bool isShowDialog; //true
  Color textColor;
  Color? color;
  EdgeInsetsGeometry padding;
  TextStyle? textStyle;
  SuccessFuncMethod successFunc;
  StateFuncMethod? stateFunc;
  MoreFuncMethod? moreFunc;
  OnPressed? onPress; //Map
  onAsyncPressed? onAsyncPress; //Map<>
  Function? errorFunc; //
  ValidFuncMethod? validFunc;
  ReqType requestType;
  bool isDisable;
  double borderRadius;
  BorderRadius? bRadius;
  bool showErrSnack;
  Widget? icon;
  Widget? loadingWidget;
  bool showLoading;
  Color borderColor;
  double borderWidth;
  bool isAlreadyFormData;
  TextAlign? align;
  String? tempId;
  bool isCupertino;

  RequestButton(
      {required this.url,
      required this.text,
      this.scaffoldState,
      required this.successFunc,
      this.stateFunc,
      this.moreFunc,
      this.errorFunc,
      this.isAlreadyFormData = false,
      this.showLoading = true,
      this.onPress,
      this.onAsyncPress,
      this.changeFormData = false,
      this.textColor = Colors.white,
      this.color,
      this.padding = const EdgeInsets.all(10),
      this.isShowDialog = false,
      this.textStyle,
      this.align,
      this.validFunc,
      this.requestType = ReqType.Post,
      this.isDisable = false,
      this.borderRadius = 5,
      this.bRadius,
      this.showErrSnack = true,
      this.icon,
      this.loadingWidget,
      this.borderColor = Colors.transparent,
      this.isCupertino = false,
      this.borderWidth = 0.0,
      this.tempId = ''});

  @override
  _RequestButtonState createState() => _RequestButtonState();
}

class _RequestButtonState extends State<RequestButton> {
  final _bloc = RequestButtonBloc();

  bool isShowingDialog = false;

  @override
  void initState() {
    super.initState();

    _bloc.getRequestStream().listen((ResponseOb resp) {
      if (widget.stateFunc != null) {
        widget.stateFunc!(resp);
      }

      if (resp.message == MsgState.data) {
        if (widget.isShowDialog) {
          if (isShowingDialog) {
            Navigator.of(context).pop();
          }
        }
        widget.successFunc(resp);
      }

      if (resp.message == MsgState.more) {
        if (widget.isShowDialog) {
          if (isShowingDialog) {
            Navigator.of(context).pop();
          }
        }
        if (widget.errorFunc == null) {
          if (widget.showErrSnack) {
            // AppUtils.moreResponse(resp, context);
          }
          if (widget.moreFunc != null) {
            Map<String, dynamic> moreMap = resp.data;
            widget.moreFunc!(resp);
          } else if (widget.moreFunc == null) {
            Map<String, dynamic> moreMap = resp.data;
          }
        } else {
          widget.errorFunc!();
        }
      }

      if (resp.message == MsgState.error) {
        if (resp.errState == ErrState.no_login) {
          //&& widget.errorFunc == null
        }

        if (widget.isShowDialog) {
          if (isShowingDialog) {
            Navigator.of(context).pop();
          }
        }

        if (widget.errorFunc == null) {
          if (widget.scaffoldState != null) {
            ToastHelper.checkError(resp, context: context);
          } else {
            if (widget.showErrSnack) {
              // ToastHelper.showErrorToast(title: "Error", context: context);
              // toastification.show(
              //   context: context, // optional if you use ToastificationWrapper
              //   title: Text('Hello, world!'),
              //   autoCloseDuration: const Duration(seconds: 5),
              // );

              ToastHelper.checkError(resp, context: context);
            } else {
              if (resp.errState == ErrState.server_error) {
                ToastHelper.showErrorToast(
                    title: "Internal Server Error", context: context);
              }

              if (resp.errState == ErrState.no_internet) {
                // ToastHelper.sh("No Internet connection!", color: Colors.redAccent,context: context);
                ToastHelper.showErrorToast(
                    title: "No Internet connection!", context: context);
              }

              if (resp.errState == ErrState.not_found) {
                ToastHelper.showErrorToast(
                    title: "Your requested data not found!", context: context);
              }

              if (resp.errState == ErrState.connection_timeout) {
                ToastHelper.showErrorToast(
                    title: "Connection Timeout! Try Again!", context: context);
              }
            }
          }
        } else {
          widget.errorFunc!();
          if (widget.showErrSnack) {
            if (widget.scaffoldState != null) {
              ToastHelper.checkError(resp, context: context);
            } else {
              ToastHelper.checkError(resp, context: context);
            }
          }
        }

        if (resp.errState == ErrState.validate_err) {
          if (widget.validFunc != null) {
            resp.data = json.decode(resp.data);
            widget.validFunc!(resp);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ResponseOb>(
      initialData: ResponseOb(),
      stream: _bloc.getRequestStream(),
      builder: (context, snapshot) {
        ResponseOb? resp = snapshot.data;
        if (widget.showLoading) {
          if (resp!.message == MsgState.loading &&
              widget.isShowDialog == false) {
            return Center(
              child: widget.loadingWidget ?? LoadingWidget(),
            );
          } else {
            return widget.isCupertino ? cupertinoWidget() : mainWidget();
          }
        } else {
          return widget.isCupertino ? cupertinoWidget() : mainWidget();
        }
      },
    );
  }

  Widget cupertinoWidget() {
    return CupertinoButton(
        padding: widget.padding,
        borderRadius: widget.bRadius == null
            ? BorderRadius.circular(widget.borderRadius)
            : widget.bRadius!,
        onPressed: widget.isDisable
            ? null
            : () async {
                if (widget.onPress != null) {
                  if (widget.onPress!() != null) {
                    Map<String, dynamic> map = widget.onPress!();

                    checkDialog();
                    if (map['is_logout'] == true) {
                      debugPrint(
                          'is_logout=true, skip NotificationSubscribeService.logoutSubscribe');
                    }
                    if (widget.isAlreadyFormData) {
                      _bloc.postData(
                        widget.url,
                        fd: widget.onPress!(),
                        requestType: widget.requestType,
                      );
                    } else {
                      if (!widget.changeFormData) {
                        _bloc.postData(
                          widget.url,
                          map: widget.onPress!(),
                          requestType: widget.requestType,
                        );
                      } else {
                        FormData fd = FormData.fromMap(widget.onPress!());
                        _bloc.postData(
                          widget.url,
                          fd: fd,
                          requestType: widget.requestType,
                        );
                      }
                    }
                  }
                } else {
                  await widget.onAsyncPress!()!.then((a) {
                    if (a != null) {
                      checkDialog();
                      if (widget.requestType == ReqType.Get) {
                        _bloc.postData(
                          widget.url,
                          map: a,
                          requestType: widget.requestType,
                        );
                      } else {
                        FormData fd = FormData.fromMap(a);
                        _bloc.postData(
                          widget.url,
                          fd: fd,
                          requestType: widget.requestType,
                        );
                      }
                    }
                  });
                }
              },
        child: widget.icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.icon!,
                  SizedBox(
                    width: 5,
                  ),
                  Flexible(
                      child: Text(
                    widget.text!,
                    style: widget.textStyle ??
                        Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  )),
                ],
              )
            : Center(
                child: Text(
                  widget.text!,
                  style: widget.textStyle ??
                      Theme.of(context).textTheme.labelMedium,
                ),
              ));
  }

  Widget mainWidget() {
    return Consumer<ThemeProvider>(
        builder: (context, ThemeProvider provider, child) {
      return TextButton.icon(
        style: TextButton.styleFrom(
          shape: widget.isCupertino
              ? RoundedRectangleBorder()
              : RoundedRectangleBorder(
                  borderRadius: widget.bRadius == null
                      ? BorderRadius.circular(widget.borderRadius)
                      : widget.bRadius!,
                  side: BorderSide(
                      color: widget.borderColor, width: widget.borderWidth)),
          padding: widget.padding,
          backgroundColor: widget.color ?? Theme.of(context).primaryColor,
          foregroundColor: provider.themeMode == ThemeMode.dark
              ? Colors.black
              : Colors.white,
          // disabledColor: Colors.grey,
        ),
        onPressed: widget.isDisable
            ? null
            : () async {
                if (widget.onPress != null) {
                  // if (widget.onPress!() != null) {

                  checkDialog();
                  if (widget.isAlreadyFormData) {
                    _bloc.postData(widget.url,
                        fd: widget.onPress!(),
                        requestType: widget.requestType,
                        tempId: widget.tempId);
                  } else {
                    if (!widget.changeFormData) {
                      _bloc.postData(widget.url,
                          map: await widget.onPress!(),
                          requestType: widget.requestType,
                          tempId: widget.tempId);
                    } else {
                      FormData fd = FormData.fromMap(widget.onPress!());
                      _bloc.postData(widget.url,
                          fd: fd,
                          requestType: widget.requestType,
                          tempId: widget.tempId);
                    }
                  }
                  // }
                } else {
                  await widget.onAsyncPress!()!.then((a) {
                    if (a != null) {
                      checkDialog();
                      if (widget.requestType == ReqType.Get) {
                        _bloc.postData(widget.url,
                            map: a,
                            requestType: widget.requestType,
                            tempId: widget.tempId);
                      } else {
                        FormData fd = FormData.fromMap(a);
                        _bloc.postData(widget.url,
                            fd: fd,
                            requestType: widget.requestType,
                            tempId: widget.tempId);
                      }
                    }
                  });
                }
              },
        label: Text(
          widget.text!,
          style: widget.textStyle,
          textAlign: TextAlign.center,
        ),
        icon: widget.icon == null ? null : widget.icon,
      );
    });
  }

  checkDialog() async {
    if (widget.isShowDialog) {
      isShowingDialog = true;
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
        isShowingDialog = false;
      });
    }
  }

  @override
  void dispose() {
    _bloc.disponse();
    super.dispose();
  }
}
''';
