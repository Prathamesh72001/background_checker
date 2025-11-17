import 'dart:io';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_time_tracker/view/screens/dashboard/screen/dashboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'constants/sizes.dart';
import 'constants/strings.dart';
import 'core/db/db_provider.dart';
import 'core/router/router.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await DBProvider.instance.init(); // initialize sqlite

  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      title: Strings.app_name,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const SafeArea(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, __) {
        return Builder(
          builder: (context) {
            Sizes.init(context);
            return MaterialApp(
              title: Strings.app_name,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primaryColor,
                ),
              ),
              home: DashboardView(),
              navigatorKey: AppRouter.navigatorKey,
              debugShowCheckedModeBanner: false,
              onGenerateRoute: (settings) {
                return AppRouter.fadeRoute(settings.name!, arguments: settings.arguments);
              },
            );
          },
        );
      },
    );
  }
}