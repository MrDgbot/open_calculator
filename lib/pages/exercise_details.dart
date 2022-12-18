import 'package:eval_ex/expression.dart';
import 'package:open_calculator/apis/repo.dart';
import 'package:open_calculator/common/extension.dart';
import 'package:open_calculator/common/log.dart';
import 'package:open_calculator/common/screen.dart';
import 'package:open_calculator/model/exercise_details.dart';
import 'package:flutter/material.dart';
import 'package:open_calculator/topvars.dart';

/// 习题展示页
class ExerciseDetailsPage extends StatefulWidget {
  /// 接收题目，展现列表
  final int storageId;

  /// 展示风格
  final int type;

  const ExerciseDetailsPage(
      {Key? key, required this.storageId, required this.type})
      : super(key: key);

  @override
  State<ExerciseDetailsPage> createState() => _ExerciseDetailsPageState();
}

class _ExerciseDetailsPageState extends State<ExerciseDetailsPage> {
  ExerciseDetail? _exerciseDetails;

  bool isLoading = false;

  final bool _isSubmit = false;

  List<TextEditingController> _controllers = [];
  List<Color> _colors = [];
  @override
  void initState() {
    super.initState();
    _getExerciseDetails();
  }

  /// 获取习题详情
  void _getExerciseDetails() async {
    try {
      var data = await Repo.getExerciseDetail(widget.storageId, filter: -1);
      if (data.success) {
        setState(() {
          isLoading = true;
          _exerciseDetails = ExerciseDetail.fromJson(data.data);

          /// 初始化控制器
          _controllers = List.filled(
              _exerciseDetails!.data!.length, TextEditingController());

          /// 初始化颜色
          _colors = List.generate(_exerciseDetails!.data!.length, (index) {
            print(_exerciseDetails!.data![index].exerciseResultStatus);
            return _exerciseDetails!.data![index].exerciseResultStatus == 1
                ? Colors.greenAccent
                : Colors.redAccent.withOpacity(0.85);
          });
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      "获取习题详情失败".toast();
      e.toString().debug();
    }
  }

  /// 单个卡片
  Widget _buildItem(int position) {
    final answer = Expression(_exerciseDetails!.data![position].exerciseContent!
            .replaceAll('=', '')
            .replaceAll("×", '*')
            .replaceAll('÷', '/'))
        .eval()
        .toString();
    return Card(
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
                    "${_exerciseDetails!.data![position].exerciseContent?.replaceAll('=', '')} = ?",
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
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 98, 101, 151),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          // 你的答案
                          Text(
                            '你的答案:${_exerciseDetails!.data![position].exerciseResult.isNullOrEmpty ? '空' : _exerciseDetails!.data![position].exerciseResult}',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          //分割线
                          const VerticalDivider(
                            width: 10,
                            color: Colors.black,
                          ),

                          /// 正确答案
                          Text(
                            '正确答案:$answer',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                      // TextField(
                      //   controller: _controllers[position],
                      //   style:
                      //       const TextStyle(fontSize: 18, color: Colors.black),
                      //   // 是否可以编辑
                      //   enabled: !_isSubmit,
                      //   decoration: const InputDecoration(
                      //     border: InputBorder.none,
                      //     hintText: '点击输入',
                      //     hintStyle: TextStyle(
                      //       fontSize: 18,
                      //       color: Colors.grey,
                      //     ),
                      //     contentPadding: EdgeInsets.only(left: 10),
                      //   ),
                      // ),
                      ),
                  const SizedBox(
                    height: 10,
                  ),
                  // 提示ROW【第X题、做题人数、正确率、收藏】
                  Row(
                    children: [
                      Text(
                        '第${position + 1}题',
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        '做题人数: 98',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        '正确率: 98.92%',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
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
  }

  /// 构建卡片根据传入的题目
  Widget _buildCard(ExerciseDetailItem item) {
    return Card(
      child: Column(
        children: [
          Text(
            item.exerciseContent!,
            style: const TextStyle(fontSize: 20, color: Colors.red),
          ),
          Text(item.exerciseResult!),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 70, 74, 121),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 70, 74, 121),
        title: const Text("做题记录",
            style: TextStyle(
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
      body: !isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _exerciseDetails == null
              ? Center(
                  child: Column(
                    children: [
                      const Text('暂无数据'),

                      /// 刷新
                      ElevatedButton(
                        onPressed: () {
                          _getExerciseDetails();
                        },
                        child: const Text('刷新'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _exerciseDetails!.data!.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (_, int position) {
                    // 一行两个,如果剩余的只有一个,则单独一行
                    if (position % 2 == 0) {
                      return Row(
                        children: [
                          Expanded(
                            child: _buildItem(position),
                          ),
                          (position + 1 < _exerciseDetails!.data!.length)
                              ? Expanded(
                                  child: _buildItem(position + 1),
                                )
                              : const Expanded(child: sizedBox),
                        ],
                      );
                    } else {
                      return sizedBox;
                    }
                  },
                ),
    );
  }
}
