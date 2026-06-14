import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/presentation/pages/ConnexionPage.dart';
import 'package:frontend/presentation/pages/InscriptionPage.dart';
import 'package:frontend/presentation/pages/UsersPage.dart';
import 'package:frontend/presentation/pages/SignalementPage.dart';
import 'package:frontend/presentation/pages/DiscussionPage.dart';

void main() {
  testWidgets('ConnexionPage affiche Email et Mot de passe', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: ConnexionPage()));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('InscriptionPage affiche Nom et Email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: InscriptionPage()));
    expect(find.text('Nom'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text("S'inscrire"), findsOneWidget);
  });

  testWidgets('UsersPage affiche titre Utilisateurs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: UsersPage()));
    expect(find.text('Utilisateurs'), findsOneWidget);
  });

  testWidgets('SignalementPage affiche champs et bouton Envoyer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: SignalementPage()));
    expect(find.text('Titre'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Envoyer'), findsOneWidget);
  });

  testWidgets('DiscussionPage affiche champ message et bouton send', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: DiscussionPage(signalementId: 1)),
    );
    expect(find.text('Écrire un message...'), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
  });
}
