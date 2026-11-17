import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seconda_esercitazione/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('S2 - Visualizzazione iniziale con stato vuoto e contatore',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    // Verifica la presenza dell'empty state
    expect(find.text('Nessuna attività presente'), findsOneWidget);
    expect(find.text('0 su 0'), findsOneWidget);
  });

  testWidgets(
      'S1 - Aggiunta attività con validazione titolo e messaggio di conferma',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    // Clicca sul pulsante per aggiungere una nuova attività
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Siamo nella schermata Nuova Attività
    expect(find.text('Nuova Attività'), findsOneWidget);

    // Tentativo di conferma senza inserire il titolo (Variante titolo mancante)
    await tester.tap(find.text('Aggiungi attività'));
    await tester.pumpAndSettle();

    // Segnalazione errore
    expect(find.text('Il titolo è obbligatorio'), findsOneWidget);

    // Inserisce il titolo e attiva 'importante'
    await tester.enterText(find.byType(TextFormField), 'Comprare il latte');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // L'errore deve essere scomparso
    expect(find.text('Il titolo è obbligatorio'), findsNothing);

    // Conferma la creazione
    await tester.tap(find.text('Aggiungi attività'));
    await tester.pumpAndSettle();

    // Ritorno all'elenco: attività presente e snackbar visibile
    expect(find.text('Comprare il latte'), findsOneWidget);
    expect(find.text('Importante'), findsOneWidget);
    expect(find.text('Da fare'), findsOneWidget);
    expect(find.text('0 su 1'), findsOneWidget);
    expect(find.textContaining('aggiunta con successo'), findsOneWidget);
  });

  testWidgets('S1 - Variante rinuncia non aggiunge alcuna attività',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    // Apre la schermata
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Preme Annulla
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    // Ritorna all'elenco invariato, nessun messaggio
    expect(find.text('Nessuna attività presente'), findsOneWidget);
  });

  testWidgets('S3 - Aggiornamento stato attività e contatore',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    // Aggiungi un'attività
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Studiare Flutter');
    await tester.tap(find.text('Aggiungi attività'));
    await tester.pumpAndSettle();

    // Stato iniziale: Da fare, 0 su 1
    expect(find.text('Da fare'), findsOneWidget);
    expect(find.text('0 su 1'), findsOneWidget);

    // Tocca la checkbox per completarla
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Stato aggiornato: Completata, 1 su 1
    expect(find.text('Completata'), findsOneWidget);
    expect(find.text('1 su 1'), findsOneWidget);

    // Tocca di nuovo per riportarla a "Da fare"
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Di nuovo da fare, 0 su 1
    expect(find.text('Da fare'), findsOneWidget);
    expect(find.text('0 su 1'), findsOneWidget);
  });

  testWidgets('S4 - Eliminazione attività con dialogo di conferma e rinuncia',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    // Aggiungi un'attività
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Attività da eliminare');
    await tester.tap(find.text('Aggiungi attività'));
    await tester.pumpAndSettle();

    expect(find.text('Attività da eliminare'), findsOneWidget);

    // Clicca sull'icona elimina
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // Compare il dialogo di conferma
    expect(find.text('Conferma eliminazione'), findsOneWidget);

    // Variante rinuncia: tocca Annulla
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    // L'attività è ancora presente
    expect(find.text('Attività da eliminare'), findsOneWidget);

    // Clicca di nuovo elimina e conferma
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();

    // L'attività è stata rimossa
    expect(find.text('Attività da eliminare'), findsNothing);
    expect(find.text('Nessuna attività presente'), findsOneWidget);
    expect(find.text('0 su 0'), findsOneWidget);
  });

  testWidgets('Persistenza - Le attività rimangono salvate riaprendo l\'app',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    // Aggiungi un'attività
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Attività persistente');
    await tester.tap(find.text('Aggiungi attività'));
    await tester.pumpAndSettle();

    expect(find.text('Attività persistente'), findsOneWidget);

    // Contrassegna come completata
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('1 su 1'), findsOneWidget);

    // "Riapriamo" l'applicazione ricostruendo il widget TodoApp da zero
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    // L'attività deve essere ancora presente e completata dopo la riapertura
    expect(find.text('Attività persistente'), findsOneWidget);
    expect(find.text('Completata'), findsOneWidget);
    expect(find.text('1 su 1'), findsOneWidget);
  });

  testWidgets('S5 - Modifica attività esistente e salvataggio',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    // Aggiungi un'attività
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Attività originale');
    await tester.tap(find.text('Aggiungi attività'));
    await tester.pumpAndSettle();

    expect(find.text('Attività originale'), findsOneWidget);

    // Clicca sull'icona di modifica
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // Verifica schermata di modifica
    expect(find.text('Modifica Attività'), findsOneWidget);
    expect(find.text('Attività originale'), findsOneWidget);
    expect(find.text('Salva modifiche'), findsOneWidget);

    // Modifica il titolo e salva
    await tester.enterText(find.byType(TextFormField), 'Attività modificata');
    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    // Verifica che il titolo sia stato aggiornato nell'elenco
    expect(find.text('Attività originale'), findsNothing);
    expect(find.text('Attività modificata'), findsOneWidget);
    expect(find.textContaining('modificata con successo'), findsOneWidget);
  });

  testWidgets('S5 - Variante rinuncia modifica non altera l\'attività',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    // Aggiungi un'attività
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Non toccarmi');
    await tester.tap(find.text('Aggiungi attività'));
    await tester.pumpAndSettle();

    // Entra in modifica
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // Modifica il testo ma poi annulla
    await tester.enterText(find.byType(TextFormField), 'Testo cambiato');
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    // L'attività deve essere rimasta invariata
    expect(find.text('Non toccarmi'), findsOneWidget);
    expect(find.text('Testo cambiato'), findsNothing);
  });
}


