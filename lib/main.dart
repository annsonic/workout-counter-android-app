import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'service/timer_service.dart';
import 'ui/setup_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  TimerService.instance.init();
  runApp(const CoachTimerApp());
}

class CoachTimerApp extends StatelessWidget {
  const CoachTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '雙人輪替教練計時器',
      theme: ThemeData.dark(),
      routes: {Routes.setup: (_) => const SetupPage()},
      initialRoute: Routes.setup,
    );
  }
}
