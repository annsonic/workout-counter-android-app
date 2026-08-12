import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coach_timer/ui/setup_page.dart';

void main() {
  group('SetupPage', () {
    testWidgets('顯示三個輸入欄位與開始訓練按鈕', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SetupPage()));

      expect(find.text('訓練參數設定'), findsOneWidget);
      expect(find.text('動作項目 (Rounds)'), findsOneWidget);
      expect(find.text('單人循環 (Sets)'), findsOneWidget);
      expect(find.text('運動時間 (秒)'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, '開始訓練'), findsOneWidget);
    });

    testWidgets('輸入超出範圍時顯示錯誤提示，且開始按鈕停用', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SetupPage()));

      // 找到「運動時間 (秒)」欄位並輸入超出範圍的值
      final Finder workField = find.byType(TextField).at(2);
      await tester.enterText(workField, '5'); // 低於 min=10
      await tester.pump();

      expect(find.text('請輸入 10 ~ 9999 的整數'), findsOneWidget);

      final ElevatedButton startButton = tester.widget(
        find.widgetWithText(ElevatedButton, '開始訓練'),
      );
      expect(startButton.onPressed, isNull);
    });

    testWidgets('離開焦點後數值會被 clamp 到合法範圍', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SetupPage()));

      final Finder roundsField = find.byType(TextField).at(0);
      await tester.enterText(roundsField, '150'); // 超出 max=99
      await tester.pump();

      // 讓欄位失去焦點觸發 onBlurClamp
      await tester.tap(find.text('訓練參數設定'));
      await tester.pump();

      final TextField field = tester.widget(roundsField);
      expect(field.controller?.text, '99');
    });
  });
}
