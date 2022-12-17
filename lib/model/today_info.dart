import 'dart:convert';
import 'dart:developer';

void tryCatch(Function? f) {
  try {
    f?.call();
  } catch (e, stack) {
    log('$e');
    log('$stack');
  }
}

class FFConvert {
  FFConvert._();
  static T? Function<T extends Object?>(dynamic value) convert =
      <T>(dynamic value) {
    if (value == null) {
      return null;
    }
    return json.decode(value.toString()) as T?;
  };
}

T? asT<T extends Object?>(dynamic value, [T? defaultValue]) {
  if (value is T) {
    return value;
  }
  try {
    if (value != null) {
      final String valueS = value.toString();
      if ('' is T) {
        return valueS as T;
      } else if (0 is T) {
        return int.parse(valueS) as T;
      } else if (0.0 is T) {
        return double.parse(valueS) as T;
      } else if (false is T) {
        if (valueS == '0' || valueS == '1') {
          return (valueS == '1') as T;
        }
        return (valueS == 'true') as T;
      } else {
        return FFConvert.convert<T>(value);
      }
    }
  } catch (e, stackTrace) {
    log('asT<$T>', error: e, stackTrace: stackTrace);
    return defaultValue;
  }

  return defaultValue;
}

class TodayInfo {
  TodayInfo({
    required this.code,
    required this.data,
    required this.msg,
  });

  factory TodayInfo.fromJson(Map<String, dynamic> json) => TodayInfo(
        code: asT<int>(json['code'])!,
        data: Data.fromJson(asT<Map<String, dynamic>>(json['data'])!),
        msg: asT<String>(json['msg'])!,
      );

  int code;
  Data data;
  String msg;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'code': code,
        'data': data,
        'msg': msg,
      };

  TodayInfo copy() {
    return TodayInfo(
      code: code,
      data: data.copy(),
      msg: msg,
    );
  }
}

class Data {
  Data({
    required this.userCount,
    required this.userErrorCount,
    required this.userSubmitCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userCount: asT<int>(json['user_count'])!,
        userErrorCount: asT<int>(json['user_error_count'])!,
        userSubmitCount: asT<int>(json['user_submit_count'])!,
      );

  int userCount;
  int userErrorCount;
  int userSubmitCount;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'user_count': userCount,
        'user_error_count': userErrorCount,
        'user_submit_count': userSubmitCount,
      };

  Data copy() {
    return Data(
      userCount: userCount,
      userErrorCount: userErrorCount,
      userSubmitCount: userSubmitCount,
    );
  }
}
