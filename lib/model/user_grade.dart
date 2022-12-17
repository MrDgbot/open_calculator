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

class UserGradeList {
  UserGradeList({
    this.data,
  });

  factory UserGradeList.fromJson(Map<String, dynamic> json) {
    final List<gradeItem>? data = json['data'] is List ? <gradeItem>[] : null;
    if (data != null) {
      for (final dynamic item in json['data']!) {
        if (item != null) {
          tryCatch(() {
            data.add(gradeItem.fromJson(asT<Map<String, dynamic>>(item)!));
          });
        }
      }
    }
    return UserGradeList(
      data: data,
    );
  }

  List<gradeItem>? data;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'data': data,
      };

  UserGradeList copy() {
    return UserGradeList(
      data: data?.map((gradeItem e) => e.copy()).toList(),
    );
  }
}

class gradeItem {
  gradeItem({
    this.easy,
    this.medium,
    this.hard,
  });

  factory gradeItem.fromJson(Map<String, dynamic> json) {
    final List<int>? easy = json['easy'] is List ? <int>[] : null;
    if (easy != null) {
      for (final dynamic item in json['easy']!) {
        if (item != null) {
          tryCatch(() {
            easy.add(asT<int>(item)!);
          });
        }
      }
    }

    final List<int>? medium = json['middle'] is List ? <int>[] : null;
    if (medium != null) {
      for (final dynamic item in json['middle']!) {
        if (item != null) {
          tryCatch(() {
            medium.add(asT<int>(item)!);
          });
        }
      }
    }

    final List<int>? hard = json['hard'] is List ? <int>[] : null;
    if (hard != null) {
      for (final dynamic item in json['hard']!) {
        if (item != null) {
          tryCatch(() {
            hard.add(asT<int>(item)!);
          });
        }
      }
    }
    return gradeItem(
      easy: easy,
      medium: medium,
      hard: hard,
    );
  }

  List<int>? easy;
  List<int>? medium;
  List<int>? hard;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'easy': easy,
        'middle': medium,
        'hard': hard,
      };

  gradeItem copy() {
    return gradeItem(
      easy: easy?.map((int e) => e).toList(),
      medium: medium?.map((int e) => e).toList(),
      hard: hard?.map((int e) => e).toList(),
    );
  }
}
