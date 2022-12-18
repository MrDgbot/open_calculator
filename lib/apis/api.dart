///
/// [Author] DG (https://github.com/MrDgbot)
/// [Date] 2022-12-01 11:00:00
///

class API {
  const API._();

  static const String apiVersion = '';
  static const String baseUrl = 'http://124.222.156.228:13131$apiVersion';
  // static const String baseUrl = 'http://127.0.0.1:6060$apiVersion';

  /// 注册
  static const String register = '$baseUrl/register';

  /// 登录
  static const String login = '$baseUrl/login';

  /// 提交题目
  static const String submitList = '$baseUrl/submit_list';

  /// 用户做题记录
  static const String getUserStorage = '$baseUrl/get_user_storage';

  /// 根据id查询具体题目
  static const String getUserExercise = '$baseUrl/get_user_exercise';

  /// 首页显示
  static const String getToday = '$baseUrl/today_info';

  /// 用户每日做题量
  static const String getUserStorageCount = '$baseUrl/get_user_storage_count';

  /// 用户每日正确和错误量
  static const String getUserExerciseCount = '$baseUrl/get_user_exercise_count';

  /// 获取csv
  static const String getCsv = '$baseUrl/get_csv';

  /// 修改年级
  static const String updateGrade = '$baseUrl/update_grade';

  /// 获取错题记录
  static const String getErrorCount = '$baseUrl/get_user_error_count';

  /// 上传错题记录
  static const String uploadErrorExercise = '$baseUrl/update_list';

  /// 导入csv文件
  static const String uploadCsv = '$baseUrl/upload_csv';
}
