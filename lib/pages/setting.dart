import 'package:flutter/material.dart';

/// 设置页面
/// 显示各个年级的难度
/// 显示各个年级的题目数量
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        /// 显示各个年级的难度
        Text('各个年级的题目数量和题目长度'),
      ],
    );
  }
}
