import 'package:open_calculator/apis/repo.dart';
import 'package:open_calculator/common/extension.dart';
import 'package:open_calculator/common/storage.dart';
import 'package:open_calculator/common/user_util.dart';

class UserManager {
  // 静态变量
  static final UserManager _instance = UserManager._internal();

  // 工厂构造函数
  factory UserManager() => _instance;

  // 私有构造函数
  UserManager._internal();

  // 用户名
  get userName => StorageUtil.getString('userName');
  set setUserName(String value) => StorageUtil.setString('userName', value);

  // 密码
  get userPwd => StorageUtil.getString('userPwd');
  set setUserPwd(String value) => StorageUtil.setString('userPwd', value);

  // 年级
  get gradeId => StorageUtil.getString('gradeId');
  get gradeString =>
      UserUtil.numberToGrade(int.parse(StorageUtil.getString('gradeId')));
  set setGradeId(String value) => StorageUtil.setString('gradeId', value);

  // 是否登录（ StorageUtil.getBool('isLogin')）
  get isLogin => StorageUtil.getBool('isLogin');
  set setIsLogin(bool value) => StorageUtil.setBool('isLogin', value);

  // 注册
  Future<bool> register() async {
    try {
      var data = await Repo.register(userName, userPwd, gradeId);
      if (data.success && data.data['code'] == 200) {
        return true;
      } else {
        data.data['msg'].toString().toast();
        return false;
      }
    } catch (e) {
      e.toString().toast();
      return false;
    }
  }

  /// 登录
  Future<bool> login() async {
    try {
      var data = await Repo.login(userName, userPwd);
      if (data.success && data.data['code'] == 200) {
        return true;
      } else {
        data.data['msg'].toString().toast();
        return false;
      }
    } catch (e) {
      e.toString().toast();
      return false;
    }
  }

  /// 登出
  void logout() {
    StorageUtil.remove('userName');
    StorageUtil.remove('userPwd');
    StorageUtil.remove('gradeId');
    StorageUtil.remove('isLogin');
    setIsLogin = false;
  }
}
