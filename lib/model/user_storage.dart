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

class UserStorage {
  UserStorage({
    this.code,
    this.data,
    this.msg,
  });

  factory UserStorage.fromJson(Map<String, dynamic> json) {
    final List<storageItem>? data =
        json['data'] is List ? <storageItem>[] : null;
    if (data != null) {
      for (final dynamic item in json['data']!) {
        if (item != null) {
          tryCatch(() {
            data.add(storageItem.fromJson(asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }
    return UserStorage(
      code: asT<int?>(json['code']),
      data: data,
      msg: asT<String?>(json['msg']),
    );
  }

  int? code;
  List<storageItem>? data;
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

  UserStorage copy() {
    return UserStorage(
      code: code,
      data: data?.map((storageItem e) => e.copy()).toList(),
      msg: msg,
    );
  }
}

class storageItem {
  storageItem({
    this.finishDate,
    this.gradeId,
    this.recordDate,
    this.recordScore,
    this.storageDifficulty,
    this.storageId,
  });

  factory storageItem.fromJson(Map<String, dynamic> json) => storageItem(
        finishDate: asT<String?>(json['finish_date']),
        gradeId: asT<int?>(json['grade_id']),
        recordDate: asT<String?>(json['record_date']),
        recordScore: asT<double?>(json['record_score']),
        storageDifficulty: asT<int?>(json['storage_difficulty']),
        storageId: asT<int?>(json['storage_id']),
      );

  String? finishDate;
  int? gradeId;
  String? recordDate;
  double? recordScore;
  int? storageDifficulty;
  int? storageId;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'finish_date': finishDate,
        'grade_id': gradeId,
        'record_date': recordDate,
        'record_score': recordScore,
        'storage_difficulty': storageDifficulty,
        'storage_id': storageId,
      };

  storageItem copy() {
    return storageItem(
      finishDate: finishDate,
      gradeId: gradeId,
      recordDate: recordDate,
      recordScore: recordScore,
      storageDifficulty: storageDifficulty,
      storageId: storageId,
    );
  }
}
