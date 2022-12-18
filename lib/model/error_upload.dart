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

class ErrorUpload {
  ErrorUpload({
    this.storageId,
    this.datalist,
  });

  factory ErrorUpload.fromJson(Map<String, dynamic> json) {
    final List<ErrorUploadItem>? datalist =
        json['dataList'] is List ? <ErrorUploadItem>[] : null;
    if (datalist != null) {
      for (final dynamic item in json['dataList']!) {
        if (item != null) {
          tryCatch(() {
            datalist.add(
                ErrorUploadItem.fromJson(asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }
    return ErrorUpload(
      storageId: asT<String?>(json['storage_id']),
      datalist: datalist,
    );
  }

  String? storageId;
  List<ErrorUploadItem>? datalist;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'storage_id': storageId,
        'dataList': datalist,
      };

  ErrorUpload copy() {
    return ErrorUpload(
      storageId: storageId,
      datalist: datalist?.map((ErrorUploadItem e) => e.copy()).toList(),
    );
  }
}

class ErrorUploadItem {
  ErrorUploadItem({
    this.exerciseContent,
    this.exerciseResult,
    this.exerciseResultStatus,
  });

  factory ErrorUploadItem.fromJson(Map<String, dynamic> json) =>
      ErrorUploadItem(
        exerciseContent: asT<String?>(json['exercise_content']),
        exerciseResult: asT<String?>(json['exercise_result']),
        exerciseResultStatus: asT<int?>(json['exercise_result_status']),
      );

  String? exerciseContent;
  String? exerciseResult;
  int? exerciseResultStatus;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'exercise_content': exerciseContent,
        'exercise_result': exerciseResult,
        'exercise_result_status': exerciseResultStatus,
      };

  ErrorUploadItem copy() {
    return ErrorUploadItem(
      exerciseContent: exerciseContent,
      exerciseResult: exerciseResult,
      exerciseResultStatus: exerciseResultStatus,
    );
  }
}
