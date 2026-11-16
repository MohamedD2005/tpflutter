// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/main.dart';
import 'package:my_app/pages/home.page.dart';
import 'package:my_app/pages/contacts.page.dart';

void main() {
  testWidgets('shows login screen and validates required fields',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Page Authentification'), findsOneWidget);

    await tester.tap(find.text('Connexion'));
    await tester.pumpAndSettle();

    expect(find.text('Veuillez saisir votre identifiant.'), findsOneWidget);
    expect(find.text('Veuillez saisir votre mot de passe.'), findsOneWidget);
  });

  testWidgets('home page displays dashboard tiles without image assets',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: MyApp.routes,
        home: const HomePage(),
      ),
    );

    expect(find.text('Page Home (Accueil)'), findsOneWidget);
    expect(find.text('Météo'), findsOneWidget);
    expect(find.text('Contacts'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contacts page explains when MongoDB is not configured',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Contacts()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Contacts (0)'), findsOneWidget);
    expect(find.text('Impossible de charger les contacts'), findsOneWidget);
    expect(find.textContaining('MONGO_URI'), findsOneWidget);
  });

  testWidgets('contact form validates required fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Contacts()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ajouter un contact'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    expect(find.text('Veuillez saisir le nom.'), findsOneWidget);
    expect(find.text('Veuillez saisir le prénom.'), findsOneWidget);
    expect(find.text('Veuillez saisir le téléphone.'), findsOneWidget);
  });
}
