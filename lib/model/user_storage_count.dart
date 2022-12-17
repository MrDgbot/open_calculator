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

class UserStorageCount {
  UserStorageCount({
    required this.code,
    required this.data,
    required this.msg,
  });

  factory UserStorageCount.fromJson(Map<String, dynamic> json) {
    final List<UserStorageCountItem>? data =
        json['data'] is List ? <UserStorageCountItem>[] : null;
    if (data != null) {
      for (final dynamic item in json['data']!) {
        if (item != null) {
          tryCatch(() {
            data.add(UserStorageCountItem.fromJson(
                asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }
    return UserStorageCount(
      code: asT<int>(json['code'])!,
      data: data!,
      msg: asT<String>(json['msg'])!,
    );
  }

  int code;
  List<UserStorageCountItem> data;
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

  UserStorageCount copy() {
    return UserStorageCount(
      code: code,
      data: data.map((UserStorageCountItem e) => e.copy()).toList(),
      msg: msg,
    );
  }
}

class UserStorageCountItem {
  UserStorageCountItem({
    required this.count,
    required this.recordDate,
  });

  factory UserStorageCountItem.fromJson(Map<String, dynamic> json) =>
      UserStorageCountItem(
        count: asT<String>(json['count'])!,
        recordDate: asT<String>(json['record_date'])!,
      );

  String count;
  String recordDate;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'count': count,
        'record_date': recordDate,
      };

  UserStorageCountItem copy() {
    return UserStorageCountItem(
      count: count,
      recordDate: recordDate,
    );
  }
}
