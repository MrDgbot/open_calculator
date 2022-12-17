import 'dart:io';
import 'dart:isolate';

import 'package:open_calculator/common/log.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:isolate/isolate_runner.dart';
import 'package:isolate/load_balancer.dart';
import 'package:open_calculator/apis/api.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'store.dart';

class _BaseInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    const int timeout = 60 * 1000;
    options.baseUrl = API.baseUrl;
    options.connectTimeout = timeout;
    options.receiveTimeout = timeout;
    options.headers["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/86.0.4240.75 "
        "Safari/537.36 "
        "CalculationFlutter/x.x.x";
    options.headers['client'] = "calculation_flutter";
    options.headers['os'] = Platform.operatingSystem;
    options.headers['osv'] = Platform.operatingSystemVersion;
    super.onRequest(options, handler);
  }
}

class _Http extends DioForNative {
  _Http({
    String? cookiesDir,
    BaseOptions? options,
  }) : super(options) {
    // this.httpClientAdapter = Http2Adapter(ConnectionManager());
    // (this.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (client) {
    //   // config the http client
    //   client.findProxy = (url) {
    //     return HttpClient.findProxyFromEnvironment(url, environment: {
    //       "http_proxy": "http://192.168.101.6:8888",
    //       "https_proxy": "https://192.168.101.6:8888"
    //     });
    //   };
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;
    //   // you can also create a HttpClient to dio
    //   // return HttpClient();
    // };
    interceptors
      ..add(_BaseInterceptor())
      ..add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          request: false,
          requestBody: false,
          responseBody: false,
          error: false,
          // logPrint: (m) => (m.debug()), // 日志输出
        ),
      )
      ..add(CookieManager(PersistCookieJar(storage: FileStorage(cookiesDir))));
  }
}

final Future<LoadBalancer> loadBalancer =
    LoadBalancer.create(1, IsolateRunner.spawn);

class _Fetcher {
  late final _Http _http;

  static _Fetcher? _fetcher;

  factory _Fetcher({
    String? cookiesDir,
  }) {
    _fetcher ??= _Fetcher._(cookiesDir: cookiesDir);
    return _fetcher!;
  }

  _Fetcher._({
    final String? cookiesDir,
  }) {
    _http = _Http(cookiesDir: cookiesDir);
  }

  static Future<Resp> _asyncInIsolate(final _Protocol proto) async {
    // final login = Store.getLogin();

    final ReceivePort receivePort = ReceivePort();
    final LoadBalancer lb = await loadBalancer;
    await lb.run(_parsingInIsolate, receivePort.sendPort);
    final SendPort sendPort = await receivePort.first;
    final ReceivePort resultPort = ReceivePort();
    proto._sendPort = resultPort.sendPort;
    // proto._token = login['token'];
    sendPort.send(proto);
    return await resultPort.first;
  }

  static _parsingInIsolate(final SendPort sendPort) async {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    receivePort.listen((final proto) async {
      try {
        final _Http http = _Fetcher(cookiesDir: proto.cookiesDir)._http;
        Response resp;

        if (proto.method == _RequestMethod.get) {
          resp = await http.get(
            proto.url,
            queryParameters: proto.queryParameters,
            options: proto.options,
          );
        } else if (proto.method == _RequestMethod.postForm) {
          resp = await http.post(
            proto.url,
            data: FormData.fromMap(proto.data),
            queryParameters: proto.queryParameters,
            options: proto.options,
          );
        } else if (proto.method == _RequestMethod.postJson) {
          resp = await http.post(
            proto.url,
            data: proto.data,
            queryParameters: proto.queryParameters,
            options: proto.options,
          );
        } else {
          return proto._sendPort
              .send(Resp(false, msg: "Not support request method."));
        }
        if (resp.statusCode == HttpStatus.ok) {
          // 登录
          // if (proto.url.toString().contains(DZUrl.baseUrl) &&
          //     resp.data != null) {
          //   if (resp.data['Code'] == -3001 && proto._token.length > 10) {
          //     Store.reToken();
          //   }
          // }

          // if (proto.method == _RequestMethod.postForm &&
          //     (resp.requestOptions.path == Api.login ||
          //         resp.requestOptions.path == MikanUrl.register)) {
          //   proto._sendPort.send(Resp(
          //     false,
          //     msg: resp.requestOptions.path == MikanUrl.login
          //         ? "登录失败，请检查帐号密码后重试"
          //         : "注册失败，请检查表单正确填写后重试",
          //   ));
          // } else {
          //   proto._sendPort.send(Resp(true, data: resp.data));
          // }
          proto._sendPort.send(Resp(true, data: resp.data));
        } else {
          proto._sendPort.send(
            Resp(
              false,
              msg: "${resp.statusCode}: ${resp.statusMessage}",
            ),
          );
        }
      } catch (exception) {
        // if (e is DioError &&
        //     e.response?.statusCode == 302 &&
        //     proto.method == _RequestMethod.postForm &&
        //     (e.requestOptions.path == MikanUrl.login ||
        //         e.requestOptions.path == MikanUrl.register ||
        //         e.requestOptions.path == MikanUrl.forgotPassword)) {
        //   proto._sendPort.send(Resp(true));
        // } else {
        //   "请求出错：$e".error();
        //   proto._sendPort.send(Resp(false, msg: e.toString()));
        // }
        "请求出错：$exception".debug();
        proto._sendPort.send(Resp(false, msg: exception.toString()));
        // await Sentry.captureException(
        //   exception,
        //   stackTrace: stackTrace,
        // );
      }
    });
  }
}

class Http {
  const Http._();

  static Future<Resp> get(
    final String url, {
    final Map<String, dynamic>? queryParameters,
    final Options? options,
  }) async {
    final _Protocol proto = _Protocol(
      url,
      _RequestMethod.get,
      queryParameters: queryParameters,
      options: options,
      cookiesDir: Store.cookiesPath,
    );
    return await _Fetcher._asyncInIsolate(proto);
  }

  static Future<Resp> postForm(
    final String url, {
    final data,
    final Map<String, dynamic>? queryParameters,
    final Options? options,
  }) async {
    final _Protocol proto = _Protocol(
      url,
      _RequestMethod.postForm,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cookiesDir: Store.cookiesPath,
    );
    return await _Fetcher._asyncInIsolate(proto);
  }

  static Future<Resp> postJSON(
    final String url, {
    final data,
    final Map<String, dynamic>? queryParameters,
    final Options? options,
  }) async {
    final _Protocol proto = _Protocol(
      url,
      _RequestMethod.postJson,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cookiesDir: Store.cookiesPath,
    );
    return await _Fetcher._asyncInIsolate(proto);
  }
}

enum _RequestMethod { postForm, postJson, get }

class _Protocol {
  final String url;
  final _RequestMethod method;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final Options? options;

  final String? cookiesDir;
  late SendPort _sendPort;
  late String? _token;

  _Protocol(
    this.url,
    this.method, {
    this.data,
    this.queryParameters,
    this.options,
    this.cookiesDir,
  });
}

class Resp {
  final dynamic data;
  final bool success;
  final String? msg;

  Resp(this.success, {this.msg, this.data});

  @override
  String toString() {
    return 'Resp{data: $data, success: $success, msg: $msg}';
  }
}
