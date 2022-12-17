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

class ExerciseDetail {
  ExerciseDetail({
    this.code,
    this.data,
    this.msg,
  });

  factory ExerciseDetail.fromJson(Map<String, dynamic> json) {
    final List<ExerciseDetailItem>? data =
        json['data'] is List ? <ExerciseDetailItem>[] : null;
    if (data != null) {
      for (final dynamic item in json['data']!) {
        if (item != null) {
          tryCatch(() {
            data.add(
                ExerciseDetailItem.fromJson(asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }
    return ExerciseDetail(
      code: asT<int?>(json['code']),
      data: data,
      msg: asT<String?>(json['msg']),
    );
  }

  int? code;
  List<ExerciseDetailItem>? data;
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

  ExerciseDetail copy() {
    return ExerciseDetail(
      code: code,
      data: data?.map((ExerciseDetailItem e) => e.copy()).toList(),
      msg: msg,
    );
  }
}

class ExerciseDetailItem {
  ExerciseDetailItem({
    this.exerciseContent,
    this.exerciseDifficulty,
    this.exerciseId,
    this.exerciseResult,
    this.exerciseResultStatus,
  });

  factory ExerciseDetailItem.fromJson(Map<String, dynamic> json) =>
      ExerciseDetailItem(
        exerciseContent: asT<String?>(json['exercise_content']),
        exerciseDifficulty: asT<int?>(json['exercise_difficulty']),
        exerciseId: asT<int?>(json['exercise_id']),
        exerciseResult: asT<String?>(json['exercise_result']),
        exerciseResultStatus: asT<int?>(json['exercise_result_status']),
      );

  String? exerciseContent;
  int? exerciseDifficulty;
  int? exerciseId;
  String? exerciseResult;
  int? exerciseResultStatus;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'exercise_content': exerciseContent,
        'exercise_difficulty': exerciseDifficulty,
        'exercise_id': exerciseId,
        'exercise_result': exerciseResult,
        'exercise_result_status': exerciseResultStatus,
      };

  ExerciseDetailItem copy() {
    return ExerciseDetailItem(
      exerciseContent: exerciseContent,
      exerciseDifficulty: exerciseDifficulty,
      exerciseId: exerciseId,
      exerciseResult: exerciseResult,
      exerciseResultStatus: exerciseResultStatus,
    );
  }
}
