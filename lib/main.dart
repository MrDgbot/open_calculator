import 'dart:async';
import 'dart:io';

import 'package:open_calculator/apis/store.dart';
import 'package:open_calculator/common/log.dart';
import 'package:open_calculator/common/storage.dart';
import 'package:open_calculator/common/theme_color.dart';
import 'package:open_calculator/common/user_util.dart';
import 'package:open_calculator/pages/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 为了在桌面上显示窗口，我们需要初始化 WindowManager
  if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
    windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow(
        const WindowOptions(
            size: Size(900, 550),
            minimumSize: Size(900, 550),
            center: true,
            backgroundColor: Colors.transparent,
            skipTaskbar: false,
            titleBarStyle: TitleBarStyle.hidden), () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// 初始化异步操作
  await _initDependencies();

  /// 全局捕获异常
  runZonedGuarded(() async {
    /// 日志上报
    // await SentryFlutter.init(
    //   (options) => options
    //     ..dsn =
    //         'https://99dc0388d72844f6a27a31a7f18b4ae1@o1421907.ingest.sentry.io/4504344557125632'
    //     ..tracesSampleRate = 1.0
    //     ..environment = 'production',
    //   appRunner: () => runApp(const MyApp()),
    // );

    runApp(const MyApp());
  }, (exception, stackTrace) async {
    'Caught unhandled exception: $exception'
        .debug(tag: '💂 runZonedGuard', stackTrace: stackTrace);
    // await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}

// 初始化操作
Future<void> _initDependencies() async {
  await StorageUtil.init();
  await Store.init();
  UserUtil.generateGradeList();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OKToast(
      position: const ToastPosition(
        align: Alignment.bottomCenter,
        offset: -72.0,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: true,
        title: '口算系统',
        themeMode: ThemeMode.dark,
        theme: ThemeColor.darkTheme,
        home: const Index(),
      ),
    );
  }
}
