import 'package:open_calculator/common/extension.dart';
import 'package:open_calculator/common/screen.dart';
import 'package:open_calculator/common/user_util.dart';
import 'package:open_calculator/model/user_manager.dart';
import 'package:open_calculator/pages/home.dart';
import 'package:open_calculator/topvars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 登录页面

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// 用户名
  final _usernameController = TextEditingController();

  /// 密码
  final _passwordController = TextEditingController();

  /// 操作时注册还是登录
  bool _isRegister = false;

  bool _isObscured = true;
  final UserManager _userManager = UserManager();

  /// 年级列表
  final _gradeList = [
    '一年级',
    '二年级',
    '三年级',
    '四年级',
    '五年级',
    '六年级',
  ];

  /// 默认年级选择
  String _grade = '一年级';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: const Color.fromARGB(255, 70, 74, 121),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: leftTips(),
              ),
              Container(
                // 圆角
                decoration: BoxDecoration(
                  color: HexColor.fromHex('#4A4E7B'),
                  borderRadius: BorderRadius.circular(20),
                ),
                margin:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Card(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 1000),
                          child: SizedBox(
                            child: SvgPicture.asset(
                              'assets/logo.svg',
                            ),
                          ),
                        ),
                      ),
                      // 如果为注册则添加下拉选择框选择年级
                      if (_isRegister) _selectBox(),
                      // 用户名输入框
                      _userInput(),
                      // 密码输入框
                      _passInput(),

                      // 登录按钮
                      Container(
                        width: Screen.screenWidth / 3.5,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                          ),
                          onPressed: () async {
                            if (_usernameController.text.length != 10) {
                              '请输入正确的学号（纯数字10位）'.toast();
                              return;
                            }

                            /// 正则判断只能输入数字
                            final reg = RegExp(r'^[0-9]+$');
                            if (!reg.hasMatch(_passwordController.text)) {
                              '请输入正确的学号（纯数字10位）'.toast();
                              return;
                            }

                            /// 准备用户数据
                            _userManager.setUserName = _usernameController.text;
                            _userManager.setUserPwd = _passwordController.text;
                            _userManager.setGradeId =
                                UserUtil.gradeToNumber(_grade).toString();

                            if (_isRegister) {
                              _userManager.setIsLogin =
                                  await _userManager.register();
                              if (_userManager.isLogin) {
                                '注册成功,即将为你登录！'.toast();
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()),
                                );
                              }
                            } else {
                              _userManager.setIsLogin =
                                  await _userManager.login();
                              if (_userManager.isLogin) {
                                '登录成功'.toast();
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()),
                                );
                              }
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 50,
                            width: Screen.screenWidth / 3.5,
                            child: Text(
                              !_isRegister ? '登   录' : '注   册',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 居右注册按钮
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 20),
                        width: Screen.screenWidth / 3.5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(child: sizedBox),
                            // 注册
                            Container(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isRegister = !_isRegister;
                                  });
                                },
                                child: Text(
                                  !_isRegister ? '注册' : "返回登录",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),

                            /// 由于接口的邮件发送功能暂时无法使用，所以暂时隐藏忘记密码功能
                            // 分割线
                            // Container(
                            //   padding: EdgeInsets.only(top: 4),
                            //   child: Text(
                            //     '|',
                            //     style: TextStyle(
                            //       color: Colors.white,
                            //       fontSize: 14,
                            //     ),
                            //   ),
                            // ),
                            // 忘记密码
                            // Container(
                            //   child: TextButton(
                            //     onPressed: () async {
                            //       var row = await DatabaseHelper.db.getOne(
                            //         table: 'users',
                            //         fields: '*',
                            //         //group: 'name',
                            //         //having: 'name',
                            //         //order: 'id desc',
                            //         // limit: 10, //10 or '10 ,100'
                            //         // where: {'email': 'xxx@dd.com'},
                            //       );
                            //       print(row);
                            //       // Navigator.push(
                            //       //   context,
                            //       //   MaterialPageRoute(builder: (context) => ForgetPassword()),
                            //       // );
                            //     },
                            //     child: Text(
                            //       '忘记密码',
                            //       style: TextStyle(
                            //         color: Colors.white,
                            //         fontSize: 14,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 密码输入框
  Container _passInput() {
    return Container(
      width: Screen.screenWidth / 3.5,
      margin: edge4,
      child: TextField(
        controller: _passwordController,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
          ),
          counterStyle: const TextStyle(
            color: Colors.white,
          ),
          labelText: '密码',
          hintText: '请输入密码',
          hintStyle: TextStyle(
            color: HexColor.fromHex('#7479C2'),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
        ),
        obscureText: _isObscured,
      ),
    );
  }

  /// 用户名输入框
  Container _userInput() {
    return Container(
      width: Screen.screenWidth / 3.5,
      margin: edge10,
      child: TextField(
        controller: _usernameController,
        style: const TextStyle(
          color: Colors.white,
        ),
        maxLength: 10,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
          ),
          counterStyle: const TextStyle(
            color: Colors.white,
          ),
          labelText: '账号',
          hintText: '请输入学号（纯数字10位）',
          hintStyle: TextStyle(
            color: HexColor.fromHex('#7479C2'),
          ),
        ),
      ),
    );
  }

  /// 选择年级
  Container _selectBox() {
    return Container(
      width: Screen.screenWidth / 3.5,
      margin: edge10,
      child: DropdownButtonFormField(
        dropdownColor: HexColor.fromHex('#4A4E7B'),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
          ),
          labelText: '年级',
          hintText: '请选择年级',
          hintStyle: TextStyle(
            color: HexColor.fromHex('#7479C2'),
          ),
        ),
        style: const TextStyle(
          color: Colors.white,
        ),
        value: _grade,
        items: _gradeList.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _grade = value.toString();
          });
        },
      ),
    );
  }

  // 左侧提示
  Container leftTips() {
    return Container(
      padding: edge10,
      margin: const EdgeInsets.only(top: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome',
            style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none),
          ),
          const Text(
            '口算练习系统',
            style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none),
          ),
          sizedBoxH24,
          Text(
            '小学生口算系统，让你的孩子在玩中学，\n学中玩。超强的记忆能力'
            '快速提升学习效率。\n精致的交互体验，有趣的游戏关卡。\n无需繁琐的安装，'
            '随时随地畅玩。\n家长和老师的选择，孩子的最佳礼物。\n'
            '小学生口算系统，给孩子一个不一样的学习体验。\n马上注册登录吧!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          )
        ],
      ),
    );
  }
}
