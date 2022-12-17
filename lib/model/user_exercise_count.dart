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

class UserExerciseCount {
  UserExerciseCount({
    required this.code,
    required this.data,
    required this.msg,
  });

  factory UserExerciseCount.fromJson(Map<String, dynamic> json) {
    final List<UserExerciseCountItem>? data =
        json['data'] is List ? <UserExerciseCountItem>[] : null;
    if (data != null) {
      for (final dynamic item in json['data']!) {
        if (item != null) {
          tryCatch(() {
            data.add(UserExerciseCountItem.fromJson(
                asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }
    return UserExerciseCount(
      code: asT<int>(json['code'])!,
      data: data!,
      msg: asT<String>(json['msg'])!,
    );
  }

  int code;
  List<UserExerciseCountItem> data;
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

  UserExerciseCount copy() {
    return UserExerciseCount(
      code: code,
      data: data.map((UserExerciseCountItem e) => e.copy()).toList(),
      msg: msg,
    );
  }
}

class UserExerciseCountItem {
  UserExerciseCountItem({
    required this.correctCount,
    required this.errorCount,
    required this.recordDate,
  });

  factory UserExerciseCountItem.fromJson(Map<String, dynamic> json) =>
      UserExerciseCountItem(
        correctCount: asT<String>(json['correct_count'])!,
        errorCount: asT<String>(json['error_count'])!,
        recordDate: asT<String>(json['record_date'])!,
      );

  String correctCount;
  String errorCount;
  String recordDate;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'correct_count': correctCount,
        'error_count': errorCount,
        'record_date': recordDate,
      };

  UserExerciseCountItem copy() {
    return UserExerciseCountItem(
      correctCount: correctCount,
      errorCount: errorCount,
      recordDate: recordDate,
    );
  }
}
