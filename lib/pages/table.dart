import 'package:open_calculator/apis/repo.dart';
import 'package:open_calculator/common/config.dart';
import 'package:open_calculator/common/extension.dart';
import 'package:open_calculator/common/screen.dart';
import 'package:open_calculator/common/user_util.dart';
import 'package:open_calculator/model/user_manager.dart';
import 'package:open_calculator/model/user_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

class TablePage extends StatefulWidget {
  const TablePage({Key? key}) : super(key: key);

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final leftColWidth = Screen.screenWidth / 7;
  final rightTitleLs = ['做题年级', '难度', '用时', '正确率', '更多'];
  UserStorage? userStorage;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  getUserInfo() async {
    var data = await Repo.getUserStorage(UserManager().userName);

    try {
      if (data.success) {
        userStorage = UserStorage.fromJson(data.data);
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final rightColWidth = size.width - leftColWidth;

    return Container(
      padding: const EdgeInsets.all(Config.padding3),
      child: Card(
          color: const Color.fromARGB(255, 98, 101, 151),
          margin: const EdgeInsets.all(Config.padding1),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : userStorage == null
                  ? const Center(
                      child:
                          Text('暂无数据', style: TextStyle(color: Colors.white)),
                    )
                  : userStorage!.data.isNullOrEmpty
                      ? const Center(
                          child: Text('还没有开始做题哦～',
                              style: TextStyle(color: Colors.white)),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 200,
                            child: HorizontalDataTable(
                              leftHandSideColumnWidth: leftColWidth,
                              rightHandSideColumnWidth: rightColWidth,
                              isFixedHeader: true,
                              headerWidgets: _getTitleWidget(rightColWidth),
                              leftSideItemBuilder: _generateFirstColumnRow,
                              rightSideItemBuilder: (_, i) =>
                                  _generateRightHandSideColumnRow(
                                      _, i, rightColWidth),
                              itemCount: userStorage!.data!.length,
                              rowSeparatorWidget: const Divider(
                                color: Colors.black54,
                                height: 1.0,
                                thickness: 0.0,
                              ),
                              leftHandSideColBackgroundColor:
                                  const Color.fromARGB(255, 98, 101, 151),
                              rightHandSideColBackgroundColor:
                                  const Color.fromARGB(255, 98, 101, 151),
                            ),
                          ),
                        )),
    );
  }

  List<Widget> _getTitleWidget(double width) {
    return [
      _getTitleItemWidget('题号', leftColWidth),
      ...rightTitleLs.map((e) => _getTitleItemWidget(e, width / 7)).toList(),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      width: width,
      height: 48,
      color: const Color.fromARGB(255, 102, 105, 162),
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.center,
      child: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      width: leftColWidth,
      height: 96,
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.center,
      child: Text(
        'No.${index + 1}',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  /// 数字转年级中文
  String diff2String(String grade) {
    return {
      '1': '简单',
      '2': '中等',
      '3': '困难',
    }[grade]!;
  }

  Widget _generateRightHandSideColumnRow(
      BuildContext context, int index, double width) {
    DateTime date1 = DateTime.parse(userStorage!.data![index].recordDate!);
    DateTime date2 = DateTime.parse(userStorage!.data![index].finishDate!);
    Duration difference = date2.difference(date1);

    return Row(
      children: <Widget>[
        // 年级
        Container(
          width: width / 7,
          height: 48,
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.center,
          child: Text(
            UserUtil.numberToGrade(userStorage!.data![index].gradeId)
                .toString(),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        // 难度
        Container(
          width: width / 7,
          height: 48,
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.center,
          child: Text(
            diff2String(userStorage!.data![index].storageDifficulty.toString()),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        // 用时
        Container(
          width: width / 7,
          height: 48,
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.center,
          child: Text(
            "${difference.inHours % 24}时${difference.inMinutes % 60}分${difference.inSeconds % 60}秒",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        // 正确率
        Container(
          width: width / 7,
          height: 48,
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.center,
          child: Text(
            '${(userStorage!.data![index].recordScore! * 100).toStringAsFixed(2)}%',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        // 更多按钮点击跳转
        Column(
          children: [
            Container(
              width: width / 6.8,
              height: 48,
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              alignment: Alignment.center,
              child: OutlinedButton(
                  onPressed: () async {
                    String? dir = await FilePicker.platform.getDirectoryPath();
                    if (dir != null) {
                      print(dir);
                      setState(() {});
                      await Repo.downloadCSV(
                              dir, userStorage!.data![index].storageId)
                          .then((value) {
                        if (value) {
                          "导出成功".toast();
                        } else {
                          "导出成功".toast();
                        }
                      });
                      // 输出csv文件到路径
                      // String csv = await StorageService.exportCsv(
                      //     userStorage!.data![index].storageId);
                    }
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => StorageDetailPage(
                    //       storageId: userStorage!.data![index].storageId,
                    //     ),
                    //   ),
                    // );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('导出')),
            ),
            Container(
              width: width / 6.8,
              height: 48,
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              alignment: Alignment.center,
              child: OutlinedButton(
                  onPressed: () {
                    UserUtil.generateGradeList();
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => StorageDetailPage(
                    //       storageId: userStorage!.data![index].storageId,
                    //     ),
                    //   ),
                    // );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('查看')),
            ),
          ],
        ),
        // Container(
        //   width: width / 4,
        //   height: 52,
        //   padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        //   alignment: Alignment.centerLeft,
        //   child: Row(
        //     children: <Widget>[
        //       Icon(
        //         Icons.safety_check,
        //         color: Colors.green,
        //         size: 18,
        //       ),
        //       Text(
        //         'Active',
        //         style: TextStyle(
        //           color: Colors.white,
        //         ),
        //       )
        //     ],
        //   ),
        // ),
        // if (userStorage != null)
        //   ...userStorage!.data!
        //       .map(
        //         (e) => Container(
        //           width: width / 4,
        //           height: 48,
        //           padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        //           alignment: Alignment.center,
        //           child: Text(
        //             e.storageDifficulty.toString(),
        //             style: TextStyle(
        //               color: Colors.white,
        //             ),
        //           ),
        //         ),
        //       )
        //       .toList(),
      ],
    );
  }
}
