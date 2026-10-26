// test/widget_test.dart

import 'package:campushub/main.dart';
import 'package:campushub/screens/admin/admin_shell.dart';
import 'package:campushub/screens/login_screen.dart';
import 'package:campushub/screens/student/student_shell.dart';
import 'package:campushub/data/sample_data.dart';
import 'package:campushub/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: home,
  );
}

void main() {
  testWidgets('splash screen shows branding and opens login', (tester) async {
    await tester.pumpWidget(const CampusHubApp());

    expect(find.text('CampusHub'), findsOneWidget);
    expect(find.text('Your campus, connected.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Demonstration accounts'), findsOneWidget);
  });

  testWidgets('student demo account opens the student shell', (tester) async {
    await tester.pumpWidget(_app(const LoginScreen()));

    await tester.ensureVisible(find.text('Student · 20240153'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Student · 20240153'));
    await tester.pump();

    await tester.ensureVisible(find.text('Log in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.byType(StudentShell), findsOneWidget);
    expect(find.text('Tasks'), findsWidgets);
  });

  testWidgets('wrong password shows an inline error', (tester) async {
    await tester.pumpWidget(_app(const LoginScreen()));

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));

    await tester.enterText(fields.at(0), '20240153');
    await tester.enterText(fields.at(1), '9999');

    await tester.tap(find.text('Log in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(
      find.text('Incorrect university ID or password. Please try again.'),
      findsOneWidget,
    );
    expect(find.byType(StudentShell), findsNothing);
  });

  testWidgets('admin shell opens the overview tab', (tester) async {
    final admin = CampusData.instance.userById(1);
    expect(admin, isNotNull);

    await tester.pumpWidget(_app(AdminShell(user: admin!)));
    await tester.pumpAndSettle();

    expect(find.text('ADMINISTRATION CONSOLE'), findsOneWidget);
    expect(find.text('Manage campus'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Users & roles'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Users & roles'), findsOneWidget);
  });
}
