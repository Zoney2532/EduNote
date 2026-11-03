import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edunote/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('assembles the logo before opening the notes page', (
    tester,
  ) async {
    await tester.pumpWidget(const EduNoteApp());

    expect(find.byKey(const Key('splash-screen')), findsOneWidget);
    expect(
      tester
          .widget<Opacity>(find.byKey(const Key('splash-fragment-0')))
          .opacity,
      0,
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byKey(const Key('splash-screen')), findsOneWidget);
    expect(
      tester
          .widget<Opacity>(find.byKey(const Key('splash-fragment-0')))
          .opacity,
      greaterThan(0),
    );

    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('splash-screen')), findsNothing);
    expect(find.byKey(const Key('app-logo')), findsOneWidget);
  });

  testWidgets('creates a note with a new subject and saves it', (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EduNoteApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-logo')), findsOneWidget);
    expect(find.text('Start with a blank page'), findsOneWidget);
    await tester.tap(find.byKey(const Key('new-note-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('create-subject-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('create-subject-field')),
      'Chemistry',
    );
    await tester.tap(find.text('Add subject'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('note-title-field')),
      'Atomic structure',
    );
    await tester.enterText(
      find.byKey(const Key('note-body-field')),
      'Protons and neutrons are found in the nucleus.',
    );
    await tester.tap(find.byKey(const Key('save-note-button')));
    await tester.pumpAndSettle();

    expect(find.text('Atomic structure'), findsOneWidget);
    expect(find.text('Chemistry'), findsWidgets);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('filters notes by subject and restores saved notes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'edunote_data',
      jsonEncode({
        'subjects': [
          'Biology',
          'History',
          'Math',
          'Literature',
          'Other',
          'Physics',
        ],
        'notes': [
          {
            'id': 'saved-note',
            'title': 'Cell notes',
            'body': 'A saved biology note.',
            'subject': 'Physics',
            'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
          },
        ],
      }),
    );

    await tester.pumpWidget(const EduNoteApp());
    await tester.pumpAndSettle();
    expect(find.text('Cell notes'), findsOneWidget);
    expect(find.text('Biology'), findsNothing);
    expect(find.text('History'), findsNothing);
    expect(find.text('Math'), findsNothing);
    expect(find.text('Literature'), findsNothing);
    expect(find.text('Other'), findsNothing);
    await tester.tap(find.text('Physics').first);
    await tester.pumpAndSettle();
    expect(find.text('Cell notes'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const EduNoteApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('All notes'));
    await tester.pumpAndSettle();
    expect(find.text('Cell notes'), findsOneWidget);
  });
}
