# To-Do List (Seconda Esercitazione)

Applicazione Flutter per la gestione di una lista di attività (to-do list)
---

## 📋 Dominio

L'app gestisce l'entità **Attività** (`Attivita`), caratterizzata da:
- **Titolo** (`titolo`): testo obbligatorio che la descrive.
- **Stato** (`completata`): *da fare* (`false`) o *completata* (`true`). Una nuova attività è sempre inizializzata a *da fare*.
- **Importanza** (`importante`): booleano che indica se l'attività è importante o no (default: `false`).

---

## 🚀 Requisiti Funzionali e Scenari Implementati

### S1 – Aggiungere un'attività (R1)
- Dalla schermata principale, toccando il pulsante **`+ Nuova attività`** si naviga verso una schermata dedicata ([`NuovaAttivitaScreen`](lib/screens/nuova_attivita_screen.dart)).
- L'utente inserisce il titolo e può contrassegnare l'attività come importante tramite uno switch dedicato.
- Al tocco di **"Aggiungi attività"**, l'app valida i campi, torna all'elenco, aggiunge l'attività e mostra una `SnackBar` temporanea di conferma.
- **Variante – titolo mancante:** se il titolo è vuoto o composto solo da spazi, viene segnalato un errore visivo e l'attività non viene creata. L'errore scompare non appena l'utente digita un titolo valido (`AutovalidateMode.onUserInteraction`).
- **Variante – rinuncia:** premendo "Annulla" o il tasto indietro del dispositivo, si torna all'elenco senza salvare e senza mostrare alcun messaggio.

### S2 – Consultare le attività (R2)
- All'avvio dell'app ([`ElencoAttivitaScreen`](lib/screens/elenco_attivita_screen.dart)), viene visualizzato l'elenco delle attività con:
  - Titolo, stato e importanza ben distinguibili (badge colorati, bordo dorato per le attività importanti, barratura per quelle completate).
  - Un pannello in alto con il **numero di attività completate sul totale** e una barra di progresso interattiva.
- **Variante – nessuna attività:** se l'elenco è vuoto, viene mostrato un messaggio illustrato che spiega come aggiungere la prima attività.

### S3 – Aggiornare lo stato di un'attività (R3)
- Toccando la card o la checkbox di un'attività, lo stato commuta istantaneamente tra *da fare* e *completata*.
- Il contatore delle attività completate e la barra di avanzamento si aggiornano in tempo reale.

### S4 – Eliminare un'attività (R4)
- Toccando l'icona del cestino di un'attività, compare un dialogo modale di conferma (`AlertDialog`).
- Se l'utente conferma, l'attività viene rimossa dall'elenco e il conteggio si aggiorna.
- **Variante – rinuncia:** premendo "Annulla" o toccando all'esterno del dialogo, l'attività non viene eliminata e rimane invariata.

### S5 – Modificare un'attività (R5)
- Toccando l'icona della matita (`Icons.edit_outlined`) o tenendo premuta a lungo la card (`onLongPress`), si apre la schermata [`NuovaAttivitaScreen`](lib/screens/nuova_attivita_screen.dart) precompilata con i dati attuali dell'attività.
- L'utente può modificare il titolo, contrassegnare l'attività come importante o alternarne lo stato di completamento.
- Toccando **"Salva modifiche"**, l'attività viene aggiornata nella lista e persistita su disco tramite `shared_preferences`, mostrando una `SnackBar` di conferma.
- **Variante – rinuncia:** premendo "Annulla" o tornando indietro, nessuna modifica viene applicata.

---

## 📂 Struttura del Progetto

```
lib/
├── main.dart                          # Entrypoint dell'applicazione e configurazione tema (Material 3)
├── models/
│   └── attivita.dart                  # Modello dati dell'entità Attività
└── screens/
    ├── elenco_attivita_screen.dart    # Schermata principale (elenco, statistiche, cancellazione, modifica)
    └── nuova_attivita_screen.dart     # Schermata di inserimento/modifica (form, validazione)
test/
└── widget_test.dart                   # Test automatici per tutti gli scenari e varianti (S1-S5)
```

---
