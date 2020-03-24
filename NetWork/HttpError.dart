import 'package:dio/dio.dart';

/*
 * 网络错误表达类，根据项目实际情况，修改提示语，或者新增错误类型
 */

class HttpError {

  String code;

  String message;

  HttpError(this.code, this.message);

  /// 未联网提示语
  static const String NETWORK_ERROR_MSG = "请检查您的网络！";
  /// 网络请求异常提示语（连接失败等）
  static const String UNKNOWN_ERROR_MSG = "网络连接异常，请稍后再试！";



  ///未知错误
  static const String UNKNOWN = "UNKNOWN";

  ///解析错误
  static const String PARSE_ERROR = "PARSE_ERROR";

  ///网络错误
  static const String NETWORK_ERROR = "NETWORK_ERROR";

  ///协议错误
  static const String HTTP_ERROR = "HTTP_ERROR";

  ///证书错误
  static const String SSL_ERROR = "SSL_ERROR";

  ///连接超时
  static const String CONNECT_TIMEOUT = "CONNECT_TIMEOUT";

  ///响应超时
  static const String RECEIVE_TIMEOUT = "RECEIVE_TIMEOUT";

  ///发送超时
  static const String SEND_TIMEOUT = "SEND_TIMEOUT";

  ///网络请求取消
  static const String CANCEL = "CANCEL";

  /// dio error 处理
  HttpError.dioError(DioError error) {
    message = error.message;
    switch (error.type) {
      case DioErrorType.CONNECT_TIMEOUT:
        code = CONNECT_TIMEOUT;
        message = "网络连接超时，请检查网络设置";
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        code = RECEIVE_TIMEOUT;
        message = "请求超时，请稍后重试！";
        break;
      case DioErrorType.SEND_TIMEOUT:
        code = SEND_TIMEOUT;
        message = "网络连接超时，请检查网络设置";
        break;
      case DioErrorType.RESPONSE:
        code = HTTP_ERROR;
        message = "服务器异常，请稍后重试！";
        break;
      case DioErrorType.CANCEL:
        code = CANCEL;
        message = "请求已被取消，请重新请求";
        break;
      case DioErrorType.DEFAULT:
        code = UNKNOWN;
        message = UNKNOWN_ERROR_MSG;
        break;
    }
  }

}