import 'package:open_calculator/topvars.dart';
import 'package:open_calculator/widgets/charts/c_bar_chart.dart';
import 'package:open_calculator/widgets/charts/c_line_chart.dart';
import 'package:open_calculator/widgets/charts/legend_widget.dart';
import 'package:flutter/material.dart';

import '../common/config.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({Key? key}) : super(key: key);

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(Config.padding3),
      child: SingleChildScrollView(
        child: Wrap(
          children: [
            _chartCard(size, const CLineChart(), title: "正确率折线图"),
            _chartCard(size, const CBarChart(), title: "习题对比图"),
            // ChartCard(size, CPieChart()),
            // ChartCard(size, CRadarChart()),
          ],
        ),
      ),
    );
  }

  _chartCard(Size size, Widget child, {String? title}) => Card(
      color: const Color.fromARGB(255, 98, 101, 151),
      margin: const EdgeInsets.all(Config.padding1),
      child: Column(
        children: [
          Container(
            // width: (size.width - 180 - 50) / 2,
            alignment: Alignment.center,
            padding: edge8,
            child: Text(
              title ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          if (title == "习题对比图")
            LegendsListWidget(
              legends: [
                Legend('正确', Colors.greenAccent),
                Legend('错误', Colors.redAccent),
              ],
            ),
          Container(
            width: (size.width - 180 - 80),
            // width: size.width - 200,
            height: 180,
            padding: const EdgeInsets.all(Config.padding3),
            child: child,
          ),
        ],
      ));
}
