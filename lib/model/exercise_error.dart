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

class ErrorCount {
  ErrorCount({
    this.code,
    this.data,
    this.msg,
  });

  factory ErrorCount.fromJson(Map<String, dynamic> json) {
    final List<ErrorItem>? data = json['data'] is List ? <ErrorItem>[] : null;
    if (data != null) {
      for (final dynamic item in json['data']!) {
        if (item != null) {
          tryCatch(() {
            data.add(ErrorItem.fromJson(asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }
    return ErrorCount(
      code: asT<int?>(json['code']),
      data: data,
      msg: asT<String?>(json['msg']),
    );
  }

  int? code;
  List<ErrorItem>? data;
  String? msg;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'code': code,
        'data': data,
        'msg': msg,
      };

  ErrorCount copy() {
    return ErrorCount(
      code: code,
      data: data?.map((ErrorItem e) => e.copy()).toList(),
      msg: msg,
    );
  }
}

class ErrorItem {
  ErrorItem({
    this.count,
    this.recordDate,
    this.storageDifficulty,
    this.storageId,
  });

  factory ErrorItem.fromJson(Map<String, dynamic> json) => ErrorItem(
        count: asT<int?>(json['count']),
        recordDate: asT<String?>(json['record_date']),
        storageDifficulty: asT<int?>(json['storage_difficulty']),
        storageId: asT<int?>(json['storage_id']),
      );

  int? count;
  String? recordDate;
  int? storageDifficulty;
  int? storageId;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'count': count,
        'record_date': recordDate,
        'storage_difficulty': storageDifficulty,
        'storage_id': storageId,
      };

  ErrorItem copy() {
    return ErrorItem(
      count: count,
      recordDate: recordDate,
      storageDifficulty: storageDifficulty,
      storageId: storageId,
    );
  }
}
