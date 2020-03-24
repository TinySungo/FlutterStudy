
/*
 * Author: shenbilian
 * 
 *  RESTFul response {data:{}, msg:"". code:22}
 *  根据不同的后台返回，修改该类的属性和判断方法
 */

import 'dart:ffi';

class HttpResponse {
  /// restful
  static const String DATA = 'data';
  static const String MSG = 'message';
  static const String CODE = 'code';

  // 请求 返回类型判断是否成功
  bool requestSuccess(Map<String, dynamic> response) {
    String code = response[CODE];
    if (code == null) {
      return false;
    } 
    return code == "0"; // 也有可能是code=1 是成功，根据需求修改
  }
}