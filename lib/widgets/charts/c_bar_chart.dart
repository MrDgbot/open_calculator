import 'package:open_calculator/apis/repo.dart';
import 'package:open_calculator/model/user_manager.dart';
import 'package:open_calculator/model/user_exercise_count.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CBarChart extends StatefulWidget {
  const CBarChart({Key? key}) : super(key: key);

  @override
  State<CBarChart> createState() => _CBarChartState();
}

class _CBarChartState extends State<CBarChart> {
  final Color dark = Colors.greenAccent;

  final Color light = Colors.redAccent;
  UserExerciseCount? userExerciseCount;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  getUserInfo() async {
    var data = await Repo.getUserExerciseCount(UserManager().userName);

    try {
      if (data.success) {
        userExerciseCount = null;
        userExerciseCount = UserExerciseCount.fromJson(data.data);
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
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : userExerciseCount == null
            ? Center(
                child: Column(
                  children: [
                    Text(
                      '数据加载失败',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    // 刷新按钮
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                        });
                        getUserInfo();
                      },
                    ),
                  ],
                ),
              )
            : BarChart(barChartData());
  }

  BarChartData barChartData() => BarChartData(
        // alignment: BarChartAlignment.center,

        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipMargin: 8,
            tooltipBgColor: Colors.grey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                "正确:${rod.rodStackItems[0].toY.toStringAsFixed(0)}\n"
                "错误:${(rod.rodStackItems[1].toY - rod.rodStackItems[0].toY).toStringAsFixed(0)}",
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: bottomTitles,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: leftTitles,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white54,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
            show: true,
            border: Border(bottom: BorderSide(color: Colors.white54))),
        barGroups: getData(),
      );

  Widget bottomTitles(double value, TitleMeta meta) {
    // print("value:${value.toInt()}");
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    // print(value.toInt());
    DateTime date =
        DateTime.parse(userExerciseCount!.data[value.toInt()].recordDate);
    String text = '${date.month}-${date.day}';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    // if (value == meta.min) {
    //   return Container();
    // }
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: style,
      ),
    );
  }

  List<BarChartGroupData> getData() {
    return userExerciseCount!.data
        .map((e) => BarChartGroupData(
              x: userExerciseCount!.data.indexOf(e),
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                    width: 20,
                    toY: double.parse(e.errorCount) +
                        double.parse(e.correctCount),
                    rodStackItems: [
                      BarChartRodStackItem(
                          0, double.parse(e.correctCount), dark),
                      BarChartRodStackItem(
                          double.parse(e.correctCount),
                          double.parse(e.errorCount) +
                              double.parse(e.correctCount),
                          light),
                    ],
                    borderRadius: const BorderRadius.all(Radius.zero)),
              ],
            ))
        .toList();
  }
}
