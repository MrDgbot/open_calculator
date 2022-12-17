import 'package:open_calculator/apis/repo.dart';
import 'package:open_calculator/common/extension.dart';
import 'package:open_calculator/common/log.dart';
import 'package:open_calculator/model/exercise_details.dart';
import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
    _getExerciseDetails();
  }

  /// 获取习题详情
  void _getExerciseDetails() async {
    try {
      var data =
          await Repo.getExerciseDetail(widget.storageId, filter: widget.type);
      if (data.success) {
        setState(() {
          isLoading = true;
          _exerciseDetails = ExerciseDetail.fromJson(data.data);
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
      appBar: AppBar(
        title: const Text('习题详情'),
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
                  itemBuilder: (BuildContext context, int index) {
                    return _buildCard(_exerciseDetails!.data![index]);
                  },
                ),
    );
  }
}
