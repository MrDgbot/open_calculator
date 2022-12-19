import 'package:file_picker/file_picker.dart';
import 'package:open_calculator/apis/repo.dart';
import 'package:open_calculator/common/config.dart';
import 'package:open_calculator/common/extension.dart';
import 'package:open_calculator/common/screen.dart';
import 'package:open_calculator/model/user_manager.dart';
import 'package:open_calculator/pages/charts/charts.dart';
import 'package:open_calculator/pages/dashboard.dart';
import 'package:open_calculator/pages/table/error_table.dart';
import 'package:open_calculator/pages/login.dart';
import 'package:open_calculator/pages/table/exercise_table.dart';
import 'package:flutter/material.dart';
import 'package:open_calculator/topvars.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  final int? pageIndex;
  const HomePage({Key? key, this.pageIndex}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var curIndex = 0;
  final secondTextColor = const Color.fromARGB(255, 218, 217, 217);

  final menuLsName = [
    '首页',
    '习题分析',
    '做题记录',
    '错题巩固',
  ];

  /// 年级列表
  final _gradeList = [
    '一年级',
    '二年级',
    '三年级',
    '四年级',
    '五年级',
    '六年级',
  ];

  /// 年级选择
  final String _grade = UserManager().gradeString;

  final menuLsIcons = [
    Icons.dashboard,
    Icons.pie_chart,
    Icons.table_chart,
    Icons.account_balance
  ];
  final mainCtrl = PageController();

  @override
  void initState() {
    super.initState();

    curIndex = widget.pageIndex ?? 0;

    /// 等待构建完毕跳转
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mainCtrl.jumpToPage(curIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            leftPanel(),
            Expanded(child: mainArea()),
          ],
        ));
  }

  /// 左侧面板
  leftPanel() => Container(
        width: 180,
        color: const Color(0xff333657),
        child: Stack(
          children: [
            DragToMoveArea(child: Container()),
            Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  '口算练习',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none),
                ),
                const SizedBox(height: 20),
                Material(color: const Color(0xff333657), child: _selectBox()),
                const SizedBox(height: 20),
                Expanded(child: menus()),
                Container(
                  height: 70,
                  margin:
                      const EdgeInsets.symmetric(horizontal: Config.padding4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _importDialog();
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.all(Config.padding1 + 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: const Color.fromARGB(255, 80, 85, 138),
                              ),
                              child: Icon(
                                Icons.upload,
                                size: 15,
                                color: secondTextColor,
                              ),
                            ),
                          ),

                          /// 导入习题

                          /// 退出登录
                          GestureDetector(
                            onTap: () {
                              UserManager().logout();
                              // 跳转登录页-LoginPage()
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Config.padding2,
                                  vertical: Config.padding1),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 70, 74, 121),
                                // boxShadow: [
                                //   BoxShadow(
                                //     offset: Offset(.5, .8),
                                //   )
                                // ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.power_settings_new,
                                    color: Colors.red,
                                    size: 12,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    '退出登录',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: secondTextColor,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.none),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      );

  /// 年级选择框
  Widget _selectBox() {
    return Container(
      height: Screen.screenHeight / 16,
      margin: EdgeInsets.symmetric(horizontal: Screen.screenWidth / 22),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 71, 74, 118),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(
        children: [
          spacer,
          DropdownButton<String>(
            value: _grade,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 15,
            elevation: 16,
            dropdownColor: const Color.fromARGB(255, 71, 74, 118),
            style:
                TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
            underline: Container(),
            iconEnabledColor: Colors.white.withOpacity(0.8),
            onChanged: (String? newValue) {
              /// 弹窗确认修改
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color.fromARGB(255, 71, 74, 118),
                  title: const Text(
                    '提示',
                  ),
                  content: const Text('确定要修改年级吗？'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _confirmChangeGrade(newValue!);
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
            items: _gradeList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          spacer,
        ],
      ),
    );
  }

  /// 确认修改年级，发起网络请求
  _confirmChangeGrade(String grade) async {
    final gradeId = _gradeList.indexOf(grade) + 1;
    var data = await Repo.updateGrade(gradeId, UserManager().userName);

    if (data.success) {
      UserManager().setGradeId = gradeId.toString();
      // 刷新整个页面,取消路由动画
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const HomePage(),
            transitionDuration: const Duration(seconds: 0),
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
      "网络异常，修改失败".toast();
    }
  }

  /// 菜单
  menus() => Column(
        children: [
          for (var i in Iterable.generate(menuLsName.length))
            mMenuItem(menuLsIcons[i], menuLsName[i], i)
        ],
      );

  mMenuItem(IconData icon, String name, int index) => GestureDetector(
        onTap: () {
          setState(() {
            curIndex = index;
          });
          mainCtrl.jumpToPage(index);
        },
        child: Container(
          height: 38,
          margin: const EdgeInsets.only(
            left: 10,
            bottom: 5,
          ),
          padding: const EdgeInsets.only(
            left: 20,
          ),
          decoration: BoxDecoration(
            color: index == curIndex
                ? const Color.fromARGB(255, 90, 94, 148)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: index == curIndex ? Colors.white : secondTextColor,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: TextStyle(
                    fontSize: 14,
                    color: index == curIndex ? Colors.white : secondTextColor,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none),
              ),
              const Spacer(),
              if (index == curIndex)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  width: 8,
                  height: 30,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 74, 77, 124),
                      borderRadius: BorderRadius.circular(8)),
                ),
              const SizedBox(
                width: 4,
              )
            ],
          ),
        ),
      );

  /// 主页面
  mainArea() => Container(
        color: const Color.fromARGB(255, 74, 77, 124),
        child: PageView(
          controller: mainCtrl,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const DashBoardPage(),
            const ChartsPage(),
            const TablePage(),
            const ExerciseErrorPage(),
            ...menuLsName
                .map((e) => Container(
                      child: Center(
                        child: Text(
                          e,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none),
                        ),
                      ),
                    ))
                .skip(3)
                .toList()
          ],
        ),
      );

  /// 导入弹窗
  void _importDialog() {
    /// 弹窗选择，加入错题记录还是做题记录
    /// 选择错题记录全部重做
    /// 选择做题记录只能查看答案，重做错题部分
    showModalBottomSheet(
        backgroundColor: Colors.white.withOpacity(0.9),
        context: context,
        builder: (context) {
          return SizedBox(
            height: Screen.screenHeight / 2,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  '选择导入类型',
                  style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 70, 74, 121),
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  '只能导入csv文件，格式如下：',
                  style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 70, 74, 121),
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  '「题目编号,题目难度,题目内容,提交记录,是否正确',
                  style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 70, 74, 121),
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  '36,1,1+1,12,错误」',
                  style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 70, 74, 121),
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 70, 74, 121),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                      ),
                      onPressed: () {
                        // Navigator.pop(context);
                        _importData(0);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '导入错题记录',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '全部重做',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 70, 74, 121),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                      ),
                      onPressed: () {
                        // Navigator.pop(context);
                        _importData(1);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '导入做题记录',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '只能重做错题',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  /// 导入数据
  void _importData(int type) async {
    /// 选择文件
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) {
      "未选择文件".toast();
      return;
    }
    var data = await Repo.uploadCSV(result.files.first.path!, type);
    if (data.success) {
      if (data.data.toString().contains("成功")) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      HomePage(
                        pageIndex: type == 0 ? 3 : 2,
                      ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  }),
              (route) => route == null);
        }
        "导入成功".toast();
      } else {
        "导入失败,网络异常".toast();
      }
    }
  }
}
