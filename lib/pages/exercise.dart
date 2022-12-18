import 'dart:async';

// import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:open_calculator/apis/repo.dart';
import 'package:open_calculator/common/generator.dart';
import 'package:open_calculator/common/log.dart';
import 'package:open_calculator/common/screen.dart';
import 'package:open_calculator/common/user_util.dart';
import 'package:open_calculator/model/submit_list.dart';
import 'package:open_calculator/model/user_manager.dart';
import 'package:open_calculator/topvars.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

class ExercisePage extends StatefulWidget {
  /// 接收参数，年级和难度
  final String grade;
  final String difficulty;

  const ExercisePage({Key? key, required this.grade, required this.difficulty})
      : super(key: key);

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  double _value = 0.0;
  bool _isSubmit = false;

  /// 定时器
  late Timer? _timer;

  /// 时,分,秒
  int _hour = 0, _minute = 0, _second = 0;

  //// 正确率
  double correctRate = 0;

  /// 总题数
  int totalCount = 0;

  /// 题目数量
  List<CalculationAble> _calculationAbles = [];

  /// 文本控制器
  List<TextEditingController> _controllers = [];

  /// 手写板控制器
  // final List<DrawingController> _drawControllers = [];

  /// 颜色
  final List<Color> _colors = [];
  int currentCount = 0;
  int currentLen = 0;

  @override
  void initState() {
    super.initState();
    // 1秒后开始倒计时
    loading();
    _timer = Timer(const Duration(seconds: 1), () {
      _startTimer();
    });
  }

  String diff2String(String grade) {
    return {
      '简单': '1',
      '中等': '2',
      '困难': '3',
    }[grade]!;
  }

  /// 初始化题目
  void loading() {
    // List<String> difficulties = ['简单', '中等', '困难'];

    switch (widget.difficulty) {
      case '简单':
        currentCount = UserUtil.currentGrade?.easy![0];
        currentLen = UserUtil.currentGrade?.easy![1];
        break;
      case '中等':
        currentCount = UserUtil.currentGrade?.medium![0];
        currentLen = UserUtil.currentGrade?.medium![1];
        break;
      case '困难':
        currentCount = UserUtil.currentGrade?.hard![0];
        currentLen = UserUtil.currentGrade?.hard![1];
        break;
    }

    /// 一到二年级加减法
    final List<bool> firstGrade = [true, true, false, false];

    /// 三到六年级加减乘除
    final List<bool> otherGrade = [true, true, true, true];

    _calculationAbles = Generator().random(
        currentCount,
        currentLen,
        UserManager().gradeId == '1' || UserManager().gradeId == '2'
            ? firstGrade
            : otherGrade);

    /// 根据长度初始化控制器
    _createTextController();
  }

  /// 创建文本控制器
  void _createTextController() {
    _controllers = [];
    for (var i = 0; i < _calculationAbles.length; i++) {
      /// 创建文本控制器
      _controllers.add(TextEditingController());
      // _drawControllers.add(DrawingController(
      //     config: DrawConfig(contentType: SimpleLine).copyWith(
      //   color: Colors.white,
      // )));

      /// 创建颜色
      _colors.add(
        const Color.fromARGB(255, 57, 60, 93),
      );
    }
  }

  // 统计控制器不为空的数量
  void _count() {
    totalCount = 0;
    for (var i = 0; i < _controllers.length; i++) {
      if (_controllers[i].text.isNotEmpty) {
        totalCount++;
      }
    }
  }

  // 检查答案
  void _checkAnswer() async {
    // 初始化提交列表
    SubmitList submitList = SubmitList(
        username: UserManager().userName.toString(),
        gradeId: widget.grade.toString(),
        difficulty: diff2String(widget.difficulty),
        //取当前时间减去_value
        recordDate: DateTime.now()
            .subtract(Duration(seconds: _value.toInt()))
            .toString(),
        finishDate: DateTime.now().toString(),
        recordScore: "0",
        datalist: []);
    // 正确率
    correctRate = 0;
    // 正确数量
    int correctCount = 0;
    // 错误数量
    int errorCount = 0;

    String postResult = '';
    // 遍历 _controllers 数
    for (var i = 0; i < _controllers.length; i++) {
      postResult = _controllers[i].text;
      if (_controllers[i].text == _calculationAbles[i].result.toString()) {
        _colors[i] = Colors.green;
        // _controllers[i].text += '';
        correctCount++;
      } else {
        _colors[i] = Colors.red;
        _controllers[i].text += '[正确答案：${_calculationAbles[i].result}]';
        errorCount++;
      }

      SubmitListItem submitListItem = SubmitListItem(
        exerciseContent: _calculationAbles[i].toString(),
        exerciseResult: postResult.toString(),
        exerciseResultStatus: _colors[i] == Colors.green ? '1' : '0',
      );
      submitList.datalist.add(submitListItem);
    }

    correctRate = correctCount == 0 ? 0 : correctCount / totalCount;
    submitList.recordScore = correctRate.toStringAsFixed(2);
    // 提交答案

    var data = await Repo.submitList(submitList);
    if (data.success) {
      setState(() {
        try {
          // print("本次返回内容：");
          // print(data.data);
          data.data.toString().debug();
        } catch (e) {
          // print(e);
          e.toString().debug();
        } finally {
          setState(() {
            _isSubmit = true;
          });
        }
      });
    }
  }

  // 正计时操作【时分秒】
  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    callback(timer) => {
          setState(() {
            if (_second < 59) {
              _second++;
            } else {
              _second = 0;
              if (_minute < 59) {
                _minute++;
              } else {
                _minute = 0;
                _hour++;
              }
            }
            _value = _hour * 3600 + _minute * 60 + _second + 0.0;
            _count();
          })
        };
    _timer = Timer.periodic(oneSec, callback);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 70, 74, 121),
        title: Text('习题集 ${UserManager().gradeString} ${widget.difficulty}',
            style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        // 返回红色按钮
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton(
              // 边框调整为白色
              style: OutlinedButton.styleFrom(
                // side: BorderSide(color: Colors.white.withOpacity(1)),
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              ),
              child: Text('退出',
                  style: TextStyle(
                      fontSize: 16, color: Colors.white.withOpacity(0.6))),
              onPressed: () {
                /// 弹窗提示确认后返回
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color.fromARGB(255, 70, 74, 121),
                    title: const Text('本次做题记录将不会保存，确认退出吗？',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    actions: [
                      TextButton(
                        child: const Text('取消',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text('确认',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.6))),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        leading: Container(),
      ),
      backgroundColor: const Color.fromARGB(255, 70, 74, 121),
      body: Column(
        children: [
          Expanded(child: buildTopList()),
          // 提交卡片
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 1,
              // 顶部左右圆角
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(29),
                      topRight: Radius.circular(29))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.query_builder_outlined,
                      color: Color.fromARGB(255, 70, 74, 121),
                    ),
                    const Text(
                      '答题时间 ',
                      style: TextStyle(
                          color: Color.fromARGB(255, 70, 74, 121),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),

                    ///AnimatedFlipCounter
                    AnimatedFlipCounter(
                      value: _hour,
                      fractionDigits: 0, // decimal precision
                      suffix: "h",
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _hour >= 1 ? Colors.red : Colors.green,
                      ),
                    ),
                    AnimatedFlipCounter(
                      value: _minute,
                      fractionDigits: 0, // decimal precision
                      suffix: "m",
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _minute >= 30 ? Colors.red : Colors.green,
                      ),
                    ),
                    AnimatedFlipCounter(
                      value: _second,
                      fractionDigits: 0, // decimal precision
                      suffix: "s",
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _second >= 30 ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    const Icon(
                      Icons.text_snippet_sharp,
                      color: Color.fromARGB(255, 70, 74, 121),
                    ),
                    Text(
                      '答题进度 $totalCount/${_calculationAbles.length}',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 70, 74, 121),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    // 提交显示正确率,根据_colors数组中绿色和红色计算
                    _isSubmit
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 40,
                              ),
                              Text(
                                '正确率:${(correctRate * 100).toStringAsFixed(2)}%',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : Container(),

                    const Expanded(child: sizedBox),
                    // 绿色圆角提交按钮 左边为图标
                    submitButton(context),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  ElevatedButton submitButton(BuildContext context) {
    return ElevatedButton(
      // 边框改成圆角
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 70, 74, 121),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      ),
      child: Text(_isSubmit ? '返回' : '提交',
          style: const TextStyle(fontSize: 20, color: Colors.white)),
      onPressed: () {
        /// 弹窗提示确认后返回
        if (_isSubmit) {
          Navigator.pop(context);
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color.fromARGB(255, 70, 74, 121),
              title: const Text('确认提交吗？',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
              actions: [
                TextButton(
                  child: const Text('取消',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('确认',
                      style: TextStyle(
                          fontSize: 16, color: Colors.white.withOpacity(0.6))),
                  onPressed: () {
                    // 提示正在检查答案
                    Navigator.pop(context);
                    // if (!_isSubmit) {
                    _timer?.cancel();
                    setState(() {
                      _checkAnswer();
                    });
                    // } else {
                    //   Navigator.pop(context);
                    // }
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }

  /// 中间列表
  Container buildTopList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ListView.builder(
          itemCount: _calculationAbles.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (_, int position) {
            // 一行两个,如果剩余的只有一个,则单独一行
            if (position % 2 == 0) {
              return Row(
                children: [
                  Expanded(
                    child: _buildItem(position),
                  ),
                  (position + 1 < _calculationAbles.length)
                      ? Expanded(
                          child: _buildItem(position + 1),
                        )
                      : const Expanded(child: sizedBox),
                ],
              );
            } else {
              return sizedBox;
            }
          }),
    );
  }

  /// 单个卡片
  Widget _buildItem(int position) => Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(9))),
        color: _colors[position],
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 题目
                    Text(
                      "${_calculationAbles[position]} = ?",
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // 背景为灰色的输入框
                    Container(
                      height: Screen.screenHeight / 11,
                      decoration: BoxDecoration(
                        color: _isSubmit ? Colors.grey[400] : Colors.grey[200],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6)),
                      ),
                      child: TextField(
                        controller: _controllers[position],
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
                        // 是否可以编辑
                        enabled: !_isSubmit,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '点击输入',
                          hintStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                          contentPadding: EdgeInsets.only(left: 10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // 提示ROW【第X题、做题人数、正确率、收藏】
                    Row(
                      children: [
                        Text(
                          '第${position + 1}题',
                          style: TextStyle(
                              fontSize: 16,
                              color:
                                  _isSubmit ? Colors.white : Colors.grey[500],
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          '做题人数: 98',
                          style: TextStyle(
                              fontSize: 16,
                              color:
                                  _isSubmit ? Colors.white : Colors.grey[500],
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          '正确率: 98.92%',
                          style: TextStyle(
                              fontSize: 16,
                              color:
                                  _isSubmit ? Colors.white : Colors.grey[500],
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    // 线性收藏按钮
                    // Row(
                    //   children: [
                    //     Expanded(child: sizedBox),
                    //     OutlinedButton(
                    //       // 修改圆角
                    //       style: OutlinedButton.styleFrom(
                    //         shape: RoundedRectangleBorder(
                    //             borderRadius:
                    //                 BorderRadius.all(Radius.circular(29))),
                    //         side: BorderSide(
                    //           color: Colors.grey[500]!,
                    //           width: 1,
                    //         ),
                    //       ),
                    //       onPressed: () {},
                    //       child: Padding(
                    //         padding: const EdgeInsets.all(4.0),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.end,
                    //           children: [
                    //             Icon(
                    //               Icons.star,
                    //               color: Colors.grey[500],
                    //             ),
                    //             Text(
                    //               '收藏',
                    //               style: TextStyle(
                    //                   fontSize: 14,
                    //                   color: Colors.grey[500],
                    //                   fontWeight: FontWeight.bold),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              // 手写板
              // _drawBoard(position)
            ],
          ),
        ),
      );

  //
  // Expanded _drawBoard(int position) {
  //   return Expanded(
  //     flex: 1,
  //     child: Stack(
  //       children: [
  //         SizedBox(
  //           child: DrawingBoard(
  //             background: ClipRRect(
  //                 borderRadius: BorderRadius.circular(9),
  //                 child: Container(color: Colors.white.withOpacity(0.5))),
  //             showDefaultActions: false,
  //             showDefaultTools: false,
  //             controller: _drawControllers[position],
  //             boardScaleEnabled: false,
  //             boardPanEnabled: true,
  //           ),
  //         ),
  //
  //         /// 橡皮擦
  //         Positioned(
  //           top: 10,
  //           right: 10,
  //           child: GestureDetector(
  //             onTap: () {
  //               _drawControllers[position].clear();
  //             },
  //             child: Container(
  //               width: 30,
  //               height: 30,
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.5),
  //                 borderRadius: BorderRadius.circular(15),
  //               ),
  //               child: const Icon(
  //                 Icons.clear,
  //                 color: Colors.black,
  //                 size: 20,
  //               ),
  //             ),
  //           ),
  //         ),
  //
  //         /// 上一步
  //         Positioned(
  //           top: 10,
  //           right: 50,
  //           child: GestureDetector(
  //             onTap: () {
  //               _drawControllers[position].undo();
  //             },
  //             child: Container(
  //               width: 30,
  //               height: 30,
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.5),
  //                 borderRadius: BorderRadius.circular(15),
  //               ),
  //               child: const Icon(
  //                 Icons.undo,
  //                 color: Colors.black,
  //                 size: 20,
  //               ),
  //             ),
  //           ),
  //         ),
  //
  //         /// 下一步
  //         Positioned(
  //           top: 10,
  //           right: 90,
  //           child: GestureDetector(
  //             onTap: () {
  //               _drawControllers[position].redo();
  //             },
  //             child: Container(
  //               width: 30,
  //               height: 30,
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.5),
  //                 borderRadius: BorderRadius.circular(15),
  //               ),
  //               child: const Icon(
  //                 Icons.redo,
  //                 color: Colors.black,
  //                 size: 20,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String colorString(Color color) =>
      "#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}";

  /// 做题卡片
// Widget _itemCard({
//   required int index,
//   required String text,
//   required String answer,
// }) =>
//     Card(
//       color: Color.fromARGB(255, 98, 101, 151),
//       margin: EdgeInsets.all(Config.padding1),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           Text(
//             "题号: ${index + 1}",
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.w500,
//               color: Colors.white70,
//             ),
//           ),
//           Expanded(
//             child: SizedBox(),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(text,
//                 style: TextStyle(
//                   fontSize: 33,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white70,
//                 )),
//           ),
//           Expanded(child: SizedBox()),
//           Padding(
//             padding: const EdgeInsets.all(30.0),
//             child: TextField(
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.white70,
//               ),
//               decoration: InputDecoration(
//                 hintText: "请输入答案",
//                 hintStyle: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white70,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 50,
//           ),
//         ],
//       ),
//     );
//   _onPressed() {}
}
