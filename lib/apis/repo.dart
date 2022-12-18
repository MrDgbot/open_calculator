// import 'package:dio/dio.dart';

import 'dart:io';

import 'package:open_calculator/common/user_util.dart';
import 'package:open_calculator/model/error_upload.dart';
import 'package:open_calculator/model/submit_list.dart';
import 'package:open_calculator/model/user_manager.dart';
import 'package:dio/dio.dart';
import 'api.dart';
import 'http_util.dart';

class Repo {
  const Repo._();

  /// 注册
  static Future<Resp> register(
      String username, String password, String gradeId) async {
    final Map<String, String> params = {
      "username": username,
      "password": UserUtil.passEncrypt(password),
      "grade_id": gradeId,
    };
    return await Http.postForm(API.register, data: params);
  }

  /// 登录
  static Future<Resp> login(String username, String password) async {
    final Map<String, dynamic> params = {
      "username": username,
      "password": UserUtil.passEncrypt(password),
    };
    return await Http.postForm(API.login, data: params);
  }

  /// 获取首页今日信息
  static Future<Resp> getToday(String username) async {
    return await Http.get("${API.getToday}?username=$username");
  }

  /// 获取用户习题统计
  static Future<Resp> getUserStorage(String username) async {
    return await Http.get("${API.getUserStorage}?username=$username");
  }

  /// 用户每日做题量
  static Future<Resp> getUserStorageCount(String username) async {
    return await Http.get(
        "${API.getUserStorageCount}?username=$username&sort=asc");
  }

  /// 用户每日正确和错误量
  static Future<Resp> getUserExerciseCount(String username) async {
    return await Http.get(
        "${API.getUserExerciseCount}?username=$username&sort=asc");
  }

  static Future<Resp> submitList(SubmitList submitList) async {
    return await Http.postJSON(API.submitList, data: submitList.toString());
  }

  /// 下载csv文件到缓存目录
  static Future<bool> downloadCSV(String filePath, int? storageId) async {
    try {
      var response = await Http.get("${API.getCsv}?storage_id=$storageId",
          options: Options(responseType: ResponseType.bytes));
      File file = File("$filePath/${UserManager().userName}_$storageId.csv");
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      // 返回真
      return Future.value(true);
    } catch (e) {
      print(e);
      return Future.value(false);
    }
  }

  /// 根据id获取详细习题
  /// storage_id 习题id
  /// filter  过滤条件 -1 全部 0 错误 1 正确
  static Future<Resp> getExerciseDetail(int storageId,
      {int filter = -1}) async {
    return await Http.get(
        "${API.getUserExercise}?storage_id=$storageId&filter=$filter");
  }

  /// 修改年级
  /// grade_id 年级id
  /// username 用户名
  static Future<Resp> updateGrade(int gradeId, String username) async {
    return await Http.postForm(API.updateGrade,
        data: {"grade_id": gradeId, "user_id": username});
  }

  /// 获取错题
  static Future<Resp> getErrorExercise(String username) async {
    return await Http.get("${API.getErrorCount}?username=$username");
  }

  /// 上传错题
  static Future<Resp> uploadErrorExercise(ErrorUpload errorUpload) async {
    return await Http.postJSON(
      API.uploadErrorExercise,
      data: errorUpload.toString(),
    );
  }

  /// 上传csv文件
  static Future<Resp> uploadCSV(String path, int type) async {
    Map<String, dynamic> formData = {
      "file": await MultipartFile.fromFile(
        path,
      ),
      "username": UserManager().userName,
      "type": type,
      "gradeId": UserManager().gradeId,
    };
    return await Http.postForm(API.uploadCsv, data: formData);
  }
}
