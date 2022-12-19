import 'dart:math';

import 'package:open_calculator/common/extension.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:open_calculator/common/storage.dart';
import 'package:open_calculator/model/user_grade.dart';
import 'package:open_calculator/model/user_manager.dart';

class UserUtil {
  /// UserUtil.xxx调用
  static final UserUtil _instance = UserUtil._internal();

  /// 工厂构造函数
  factory UserUtil() => _instance;

  /// 私有构造函数
  UserUtil._internal();

  // 从数字转年级
  // 输入 1
  // 返回 一年级
  static String numberToGrade(int? grade) {
    if (grade == null) return '';
    return ['一年级', '二年级', '三年级', '四年级', '五年级', '六年级'][grade - 1];
  }

  // 从年级转数字
  // 输入一年级
  // 返回 1
  static int? gradeToNumber(String? grade) {
    if (grade.isNullOrEmpty) return null;
    return grade!.codeUnitAt(0) - '一'.codeUnitAt(0) + 1;
  }

  /// 加密密码
  static String passEncrypt(String password) {
    // Encode the data
    var data = utf8.encode(password);

    // Create an MD5 hash
    var hash = md5.convert(data);

    // Get the hexadecimal digest of the hash
    return hash.toString();
  }

  /// 创建用户等级表存储本地
  ///  {"data":[{"easy":[8,1],"middle":[11,1],"hard":[24,1]},{"easy":[7,2],"middle":[4,1],"hard":[11,2]},{"easy":[7,2],"middle":[15,1],"hard":[28,3]},{"easy":[9,1],"middle":[22,1],"hard":[26,2]},{"easy":[8,5],"middle":[11,4],"hard":[18,2]},{"easy":[12,6],"middle":[11,6],"hard":[14,4]}]}
  /// 把数据存储本地
  static generateGradeList() {
    final UserGradeList gradeList = UserGradeList(data: []);
    for (var i = 1; i <= 6; i++) {
      /// 数组[0]代表数量，
      /// 数组[1]运算数长度
      final gradeItem item = gradeItem(
        easy: [
          3 + Random().nextInt(i * 5),
          2 + Random().nextInt(i * 1),
        ],
        medium: [
          3 + Random().nextInt(i * 10),
          2 + Random().nextInt(i * 2),
        ],
        hard: [
          3 + Random().nextInt(i * 13),
          2 + Random().nextInt(i * 3),
        ],
      );
      gradeList.data?.add(item);
    }
    // print(gradeList.toString());
    StorageUtil.setString("generateGradeList", gradeList.toString());
  }

// // Create a map that maps grades to their corresponding data
//     Map<String, Map<String, List<int>>> gradeList = {
//       for (int grade = 1; grade <= 6; grade++)
//         grade.toString(): {
//           // Use the map() function to generate the data for each difficulty level
//           for (String difficulty in difficulties)
//             difficulty: [
//               3 + Random().nextInt(10 * grade),
//               2 + Random().nextInt(grade + 2)
//             ],
//         }
//     };

  static get generateGradeListData => UserGradeList.fromJson(
      jsonDecode(StorageUtil.getString("generateGradeList")));

  /// 用户当前等级的难度
  static get currentGrade => UserGradeList.fromJson(
          jsonDecode(StorageUtil.getString("generateGradeList")))
      .data![int.parse(UserManager().gradeId) - 1];
}
