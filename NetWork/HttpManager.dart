
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'HttpError.dart';
import 'HttpResponse.dart';
import 'package:connectivity/connectivity.dart';

/*
 * Author: shenbilian
 * 
 * 网络请求类，采用单例（使用工厂方法或者getInstance获取单例）
 * 
 * 网络请求类配置 : HttpManager().init(baseURL: "baseURL")
 * 
 * GET : HttpManager().get(url: "subURL", tag: "requestTAG", ...)
 * 
 * POST : HttpManager().post(url: "subURL", tag: "requestTAG", params: {} ...)
 */



/// 请求成功回调
typedef HttpSuccessCallback<T> = void Function(dynamic args);

/// 请求失败回调
typedef HttpFailureCallback<T> = void Function(HttpError errorData);


/// 数据解析回调
typedef T JsonParse<T>(dynamic data);


class HttpManager {

  ///同一个CancelToken可以用于多个请求，当一个CancelToken取消时，所有使用该CancelToken的请求都会被取消，
  /// 比如一个页面对应一个CancelToken，在页面dispose的时候，页面所有的网络请求可以一起cancel
  Map<String, CancelToken> _cancelTokens =  Map<String, CancelToken>();

  /// 超时时间
  static const int CONNECT_TIMEOUT = 1000;
  static const int RECEIVE_TIMEOUT = 10000;

  /// http request methods
  static const String GET = 'GET';
  static const String POST = 'post';

  /// 创建方法获取
  Dio _client;

  Dio get client => _client;

  static final HttpManager _instance = HttpManager.getInstance();

  // 工厂 方便创建单例
  factory HttpManager() => _instance;

  /// 创建单例请求对象
  HttpManager.getInstance() {
    if (_client == null) {
      BaseOptions option = BaseOptions(
        connectTimeout: CONNECT_TIMEOUT,
        receiveTimeout: RECEIVE_TIMEOUT,
      );
      _client = Dio(option);
    }
  }

  /// 初始化属性
  /// [baseURL] 地址前缀
  /// [connectTimeout] 连接超时时间
  /// [reciveTimeout] 接收超时时间
  /// [interceptors] 拦截器
  void init({
    String baseURL,
    int connectTimeout,
    int reciveTimeout,
    List<Interceptor> interceptors,
  }) {
  // 重新设置option
  _client.options = _client.options.merge(
    baseUrl: baseURL,
    connectTimeout: connectTimeout,
    receiveTimeout: reciveTimeout
  );

    // 拦截器
    if (interceptors != null && interceptors.isNotEmpty) {
      _client.interceptors.addAll(interceptors);
    }
  }


  /// 统一网络请求
  /// [url] 网络请求地址不包含域名
  /// [data] post 请求参数
  /// [params] url请求参数支持restful
  /// [options] 请求配置
  /// [successCallback] 请求成功回调
  /// [errorCallback] 请求失败回调
  /// [tag] 请求统一标识，用于取消网络请求
  void request({
    @required String url,
    String method,
    data,
    Map<String, dynamic> params,
    Options options,
    HttpSuccessCallback successCallback,
    HttpFailureCallback errorCallback,
    @required String tag,
  }) async {
    // 检查网络连接
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (errorCallback != null) {
        errorCallback(HttpError(HttpError.NETWORK_ERROR, HttpError.NETWORK_ERROR_MSG));
      }
      return;
    }

    // 设置默认值
    params = params ?? {};
    method = method ?? GET;

    // 设置method
    options?.method = method;
    options = options ?? Options(
      method: method
    );

    // 发起请求
    try {
      // 设置网络取消的TAG
      CancelToken cancelToken;
      if (tag != null) {
        cancelToken =
            _cancelTokens[tag] == null ? CancelToken() : _cancelTokens[tag];
        _cancelTokens[tag] = cancelToken;
      }

      // 发起请求，拿到response
      Response<Map<String, dynamic>> response = await _client.request(
        url,
        data: data, 
        queryParameters: params,
        options: options,
        cancelToken: cancelToken,
      );

      // 处理结果 restful标准 这里暂定为 根据接口情况修改
      String statusCode = response.data[HttpResponse.CODE];
      bool success = HttpResponse().requestSuccess(response.data);
      if (success) {
        //成功
        if (successCallback != null) {
          successCallback(response.data[HttpResponse.DATA]);
        }
      } else {
        //失败
        String message = response.data[HttpResponse.MSG];
        if (errorCallback != null) {
          errorCallback(HttpError(statusCode, message));
        }
      }
      
    } on DioError catch(e) { // catch DioError
      if (errorCallback != null && e.type != DioErrorType.CANCEL) {
        errorCallback(HttpError.dioError(e));
      }
    } catch (e) { // catch normalError (比如服务器连接异常等等)
      if (errorCallback != null) {
        errorCallback(HttpError(HttpError.UNKNOWN, HttpError.UNKNOWN_ERROR_MSG));
      }
    }
  }

   ///取消网络请求
  void cancel(String tag) {
    if (_cancelTokens.containsKey(tag)) {
      if (!_cancelTokens[tag].isCancelled) {
        _cancelTokens[tag].cancel();
      }
      _cancelTokens.remove(tag);
    }
  }

  ///restful处理  根据实际接口要修改这个方法的
  String restfulUrl(String url, Map<String, dynamic> params) {
    // restful 请求处理
    // ..../..../:user_id  user_id=27
    // 最终生成 url 为     /gysw/search/hist/27
    params.forEach((key, value) {
      if (url.indexOf(key) != -1) {
        url = url.replaceAll(':$key', value.toString());
      }
    });
    return url;
  }


  /// Get 请求
  /// [url] subUrl,请求地址不包括域名/baseURL
  /// [tag] 网络请求的标记，用于cancel
  /// [paras] 请求参数
  /// [options] 请求配置
  /// [successCallback] 成功回调
  /// [errorCallback] 失败回调
  void get({
    @required String url,
    @required String tag,
    Map<String, dynamic> params,
    Options options,
    HttpSuccessCallback successCallback,
    HttpFailureCallback errorCallback,
  }) async {
    request(
      url: url, 
      tag: tag, 
      params: params, 
      successCallback: successCallback, 
      errorCallback: errorCallback,
      options: options);
  }

  ///post网络请求
  ///
  ///[url] 网络请求地址不包含域名
  ///[data] post 请求参数
  ///[params] url请求参数支持restful
  ///[options] 请求配置
  ///[successCallback] 请求成功回调
  ///[errorCallback] 请求失败回调
  ///[tag] 请求统一标识，用于取消网络请求
  void post({
    @required String url,
    data,
    Map<String, dynamic> params,
    Options options,
    HttpSuccessCallback successCallback,
    HttpFailureCallback errorCallback,
    @required String tag,
  }) async {
    request(
      url: url,
      data: data,
      method: POST,
      params: params,
      successCallback: successCallback,
      errorCallback: errorCallback,
      tag: tag,
    );
  }


  ///上传文件
  ///
  ///[url] 网络请求地址不包含域名
  ///[data] post 请求参数
  ///[onSendProgress] 上传进度
  ///[params] url请求参数支持restful
  ///[options] 请求配置
  ///[successCallback] 请求成功回调
  ///[errorCallback] 请求失败回调
  ///[tag] 请求统一标识，用于取消网络请求
  void upload({
    @required String url,
    FormData data,
    ProgressCallback onSendProgress,
    Map<String, dynamic> params,
    Options options,
    HttpSuccessCallback successCallback,
    HttpFailureCallback errorCallback,
    @required String tag,
  }) async {
    //检查网络是否连接
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (errorCallback != null) {
        errorCallback(HttpError(HttpError.NETWORK_ERROR, HttpError.NETWORK_ERROR_MSG));
      }
      return;
    }

    //设置默认值
    params = params ?? {};

    //强制 POST 请求
    options?.method = POST;

    options = options ?? Options(
      method: POST,
    );

    url = restfulUrl(url, params);

    try {
      CancelToken cancelToken;
      if (tag != null) {
        cancelToken =
            _cancelTokens[tag] == null ? CancelToken() : _cancelTokens[tag];
        _cancelTokens[tag] = cancelToken;
      }

      Response<Map<String, dynamic>> response = await _client.request(url,
          onSendProgress: onSendProgress,
          data: data,
          queryParameters: params,
          options: options,
          cancelToken: cancelToken);

      String statusCode = response.data[HttpResponse.CODE];
      bool success = HttpResponse().requestSuccess(response.data);

      if (success) {
        //成功
        if (successCallback != null) {
          successCallback(response.data[HttpResponse.DATA]);
        }
      } else {
        //失败
        String message = response.data[HttpResponse.MSG];
        if (errorCallback != null) {
          errorCallback(HttpError(statusCode, message));
        }
      }
    } on DioError catch (e) {
      if (errorCallback != null && e.type != DioErrorType.CANCEL) {
        errorCallback(HttpError.dioError(e));
      }
    } catch (e) {
      if (errorCallback != null) {
        errorCallback(HttpError(HttpError.UNKNOWN, HttpError.UNKNOWN_ERROR_MSG));
      }
    }
  }


  ///下载文件
  ///
  ///[url] 下载地址
  ///[savePath]  文件保存路径
  ///[onReceiveProgress]  接受回调
  ///[data] post 请求参数
  ///[params] url请求参数支持restful
  ///[options] 请求配置
  ///[successCallback] 请求成功回调
  ///[errorCallback] 请求失败回调
  ///[tag] 请求统一标识，用于取消网络请求
  void download({
    @required String url,
    @required savePath,
    ProgressCallback onReceiveProgress,
    Map<String, dynamic> params,
    data,
    Options options,
    HttpSuccessCallback successCallback,
    HttpFailureCallback errorCallback,
    @required String tag,
  }) async {
    //检查网络是否连接
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (errorCallback != null) {
        errorCallback(HttpError(HttpError.NETWORK_ERROR, HttpError.NETWORK_ERROR_MSG));
      }
      return;
    }

    ////0代表不设置超时
    int receiveTimeout = 0;
    options ??= options == null
        ? Options(receiveTimeout: receiveTimeout)
        : options.merge(receiveTimeout: receiveTimeout);

    //设置默认值
    params = params ?? {};

    url = restfulUrl(url, params);

    try {
      CancelToken cancelToken;
      if (tag != null) {
        cancelToken =
            _cancelTokens[tag] == null ? CancelToken() : _cancelTokens[tag];
        _cancelTokens[tag] = cancelToken;
      }

      Response response = await _client.download(url, savePath,
          onReceiveProgress: onReceiveProgress,
          queryParameters: params,
          data: data,
          options: options,
          cancelToken: cancelToken);
      //成功
      if (successCallback != null) {
        successCallback(response.data);
      }
    } on DioError catch (e) {
      if (errorCallback != null && e.type != DioErrorType.CANCEL) {
        errorCallback(HttpError.dioError(e));
      }
    } catch (e) {
      if (errorCallback != null) {
        errorCallback(HttpError(HttpError.UNKNOWN, HttpError.UNKNOWN_ERROR_MSG));
      }
    }
  }


}