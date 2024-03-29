import 'package:open_calculator/apis/repo.dart';
import 'package:open_calculator/model/user_manager.dart';
import 'package:open_calculator/model/user_storage_count.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CLineChart extends StatefulWidget {
  const CLineChart({Key? key}) : super(key: key);

  @override
  State<CLineChart> createState() => _CLineChartState();
}

class _CLineChartState extends State<CLineChart> {
  UserStorageCount? userStorageCount;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  getUserInfo() async {
    var data = await Repo.getUserStorageCount(UserManager().userName);

    try {
      if (data.success) {
        userStorageCount = UserStorageCount.fromJson(data.data);
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : userStorageCount == null
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
            : LineChart(mainData());
  }

  LineChartData mainData() {
    return LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white54,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: leftTitleWidgets,
              reservedSize: 48,
            ),
          ),
        ),
        borderData: FlBorderData(
            show: true,
            border: Border(bottom: BorderSide(color: Colors.white54))),
        minX: 0,
        maxX: userStorageCount!.data.length.toDouble() - 1,
        minY: 0,
        maxY: double.parse(userStorageCount!.data.map((e) => e.count).reduce(
                (value, element) => double.parse(value) > double.parse(element)
                    ? value
                    : element)) *
            100,
        lineBarsData: [
          LineChartBarData(
            // 根据userStorageCount的data解析
            spots: userStorageCount!.data
                .map((e) => FlSpot(
                    userStorageCount!.data
                        .indexWhere(
                            (element) => element.recordDate == e.recordDate)
                        .toDouble(),
                    double.parse(e.count) * 100))
                .toList(),
            // spots: const [

            //   FlSpot(0, 3),
            //   FlSpot(2.6, 2),
            //   FlSpot(4.9, 5),
            //   FlSpot(6.8, 3.1),
            //   FlSpot(8, 4),
            //   FlSpot(10, 4),
            //   FlSpot(11, 5.5),
            // ],
            isCurved: true,
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipMargin: 8,
            tooltipBgColor: Colors.grey,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((e) {
                DateTime date = DateTime.parse(
                    userStorageCount!.data[e.spotIndex.toInt()].recordDate);
                return LineTooltipItem('正确率: \n${e.y.toStringAsFixed(2)}%',
                    TextStyle(color: Colors.white));
              }).toList();
            },
          ),
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes
                .map((e) => TouchedSpotIndicatorData(
                    FlLine(
                      color: barData.gradient!.colors[0],
                      strokeWidth: 3,
                    ),
                    FlDotData(
                      getDotPainter: (p0, p1, p2, p3) => FlDotCirclePainter(
                        color: Color.fromARGB(255, 149, 153, 234),
                        radius: 5,
                      ),
                    )))
                .toList();
          },
        ));
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    DateTime date =
        DateTime.parse(userStorageCount!.data[value.toInt()].recordDate);
    Widget text = Text('${date.month}-${date.day}', style: style);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      angle: 0.0,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = "${(value).toStringAsFixed(0)}%";
    // 间隔10个显示一次
    if (value % 50 != 0) {
      text = "";
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
