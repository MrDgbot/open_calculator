// 闪屏页
import 'package:flutter/material.dart';
import 'package:open_calculator/model/user_manager.dart';
import 'package:open_calculator/pages/home.dart';
import 'package:open_calculator/pages/login.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  @override
  Widget build(BuildContext context) {
    return UserManager().isLogin ? const HomePage() : const LoginPage();
  }
}
