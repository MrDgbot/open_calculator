import 'package:open_calculator/apis/repo.dart';
import 'package:open_calculator/common/config.dart';
import 'package:open_calculator/common/extension.dart';
import 'package:open_calculator/common/screen.dart';
import 'package:open_calculator/common/user_util.dart';
import 'package:open_calculator/model/today_info.dart';
import 'package:open_calculator/model/user_manager.dart';
import 'package:open_calculator/pages/exercise.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:bruno/bruno.dart';

// 首页
class DashBoardPage extends StatefulWidget {
  const DashBoardPage({Key? key}) : super(key: key);

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  TodayInfo? todayInfo;

  @override
  void initState() {
    super.initState();
    getTodayData();
  }

  getTodayData() async {
    var data = await Repo.getToday(UserManager().userName);
    if (data.success) {
      if (mounted) {
        setState(() {
          try {
            todayInfo = TodayInfo.fromJson(data.data);
          } catch (e) {
            print(e);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Config.padding3),
      child: Column(
        children: [
          miniInfoRow(),
          lineChartArea(),
        ],
      ),
    );
  }

  miniInfoRow() => Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Row(
          children: [
            // SizedBox(width: 15),
            MiniInfoCard('用户数量', todayInfo?.data.userCount.toString() ?? '0',
                Icons.people, const Color.fromARGB(255, 167, 130, 237)),
            MiniInfoCard(
                '今日提交',
                todayInfo?.data.userSubmitCount.toString() ?? '0',
                Icons.paid,
                Colors.orange[400]!),
            MiniInfoCard(
                '今日错误',
                todayInfo?.data.userErrorCount.toString() ?? '0',
                Icons.sticky_note_2,
                const Color.fromARGB(255, 113, 234, 236)),
            MiniInfoCard(
                '今日正确率',
                todayInfo == null
                    ? '0.0%'
                    : todayInfo!.data.userErrorCount != 0
                        ? '${((todayInfo!.data.userSubmitCount - todayInfo!.data.userErrorCount) / todayInfo!.data.userSubmitCount * 100).toDouble().toStringAsFixed(2)}%'
                        : '0.00%',
                Icons.public,
                const Color.fromARGB(255, 107, 224, 125)),
          ],
        ),
      );

  MiniInfoCard(
    String name,
    String amount,
    IconData icon,
    Color color,
  ) =>
      Expanded(
        child: Card(
          color: const Color.fromARGB(255, 98, 101, 151),
          margin: const EdgeInsets.all(Config.padding1),
          child: SizedBox(
            height: 80,
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Center(
                    child: Icon(
                      icon,
                      size: 28,
                      color: color,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        amount,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );

  lineChartArea() => Expanded(
        child: Card(
          // 统一风格，不用圆角
          // shape:
          //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(Config.padding1),
          color: const Color.fromARGB(255, 98, 101, 151),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Config.padding4, vertical: Config.padding2),
            child: _buildList(context),
          ),
        ),
      );
  // 横向排列 三个等级简单，中等，困难的卡片
  // 每个卡片里面的布局是上面是图片，下面是文字还有一个开始按钮
  final _cardMapInfo = {
    '简单': {
      'image': 'assets/easy.svg',
      'context':
          '100以内算式长度为${UserUtil.currentGrade?.easy![1].toString()}的混合四则运算，'
              '题目数量：${UserUtil.currentGrade?.easy![0].toString()}',
      'buttonColor': '#5FCE72',
      'star': '2'
    },
    '中等': {
      'image': 'assets/medium.svg',
      'context':
          '100以内算式长度为${UserUtil.currentGrade?.medium![1].toString()}的混合四则运算，'
              '题目数量：${UserUtil.currentGrade?.medium![0].toString()}',
      'buttonColor': '#FFAB40',
      'star': '3'
    },
    '困难': {
      'image': 'assets/hard.svg',
      'context':
          '100以内算式长度为${UserUtil.currentGrade?.hard![1].toString()}的混合四则运算，'
              '题目数量：${UserUtil.currentGrade?.hard![0].toString()}',
      'buttonColor': '#FF5252',
      'star': '5'
    },
  };

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      itemCount: _cardMapInfo.length,
      itemBuilder: (context, index) {
        var key = _cardMapInfo.keys.elementAt(index);
        var value = _cardMapInfo[key];
        return _buildCardItem(context, key, value!['image'], value['context'],
            buttonColor: value['buttonColor'], star: value['star']);
      },
    );
  }

  Widget _buildCardItem(
      BuildContext context, String title, String? image, String? contextString,
      {String? buttonColor, String? star}) {
    return Card(
      color: const Color.fromARGB(255, 98, 101, 151),
      margin: const EdgeInsets.all(Config.padding1),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Config.padding4, vertical: Config.padding2),
        child: Row(
          children: [
            if (image != null)
              SvgPicture.asset(image, height: Screen.screenHeight / 5),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      BrnRatingStar(
                        count: 5,
                        selectedCount: double.parse(star ?? '0'),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  if (contextString != null)
                    Text(
                      contextString,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // 按钮随机颜色
            ElevatedButton(
              onPressed: () {
                // 跳转到练习Exercise页面有两个个参数，年级和难度
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ExercisePage(
                    grade: UserManager().gradeId,
                    difficulty: title,
                    type: 0,
                  );
                }));
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: HexColor.fromHex(buttonColor ?? '#FFC107'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('开始'),
            ),
          ],
        ),
      ),
    );
  }
}
