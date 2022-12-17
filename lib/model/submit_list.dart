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

class SubmitList {
  SubmitList({
    required this.username,
    required this.gradeId,
    required this.difficulty,
    required this.recordDate,
    required this.finishDate,
    required this.recordScore,
    required this.datalist,
  });

  factory SubmitList.fromJson(Map<String, dynamic> json) {
    final List<SubmitListItem>? datalist =
        json['dataList'] is List ? <SubmitListItem>[] : null;
    if (datalist != null) {
      for (final dynamic item in json['dataList']!) {
        if (item != null) {
          tryCatch(() {
            datalist
                .add(SubmitListItem.fromJson(asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }
    return SubmitList(
      username: asT<String>(json['username'])!,
      gradeId: asT<String>(json['grade_id'])!,
      difficulty: asT<String>(json['difficulty'])!,
      recordDate: asT<String>(json['record_date'])!,
      finishDate: asT<String>(json['finish_date'])!,
      recordScore: asT<String>(json['record_score'])!,
      datalist: datalist!,
    );
  }

  String username;
  String gradeId;
  String difficulty;
  String recordDate;
  String finishDate;
  String recordScore;
  List<SubmitListItem> datalist;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'grade_id': gradeId,
        'difficulty': difficulty,
        'record_date': recordDate,
        'finish_date': finishDate,
        'record_score': recordScore,
        'dataList': datalist,
      };

  SubmitList copy() {
    return SubmitList(
      username: username,
      gradeId: gradeId,
      difficulty: difficulty,
      recordDate: recordDate,
      finishDate: finishDate,
      recordScore: recordScore,
      datalist: datalist.map((SubmitListItem e) => e.copy()).toList(),
    );
  }
}

class SubmitListItem {
  SubmitListItem({
    required this.exerciseResult,
    required this.exerciseContent,
    required this.exerciseResultStatus,
  });

  factory SubmitListItem.fromJson(Map<String, dynamic> json) => SubmitListItem(
        exerciseResult: asT<String>(json['exercise_result'])!,
        exerciseContent: asT<String>(json['exercise_content'])!,
        exerciseResultStatus: asT<String>(json['exercise_result_status'])!,
      );

  String exerciseResult;
  String exerciseContent;
  String exerciseResultStatus;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'exercise_result': exerciseResult,
        'exercise_content': exerciseContent,
        'exercise_result_status': exerciseResultStatus,
      };

  SubmitListItem copy() {
    return SubmitListItem(
      exerciseResult: exerciseResult,
      exerciseContent: exerciseContent,
      exerciseResultStatus: exerciseResultStatus,
    );
  }
}
