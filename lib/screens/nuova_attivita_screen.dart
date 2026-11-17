import 'package:flutter/material.dart';
import '../models/attivita.dart';

class NuovaAttivitaScreen extends StatefulWidget {
  final Attivita? attivita;

  const NuovaAttivitaScreen({super.key, this.attivita});

  @override
  State<NuovaAttivitaScreen> createState() => _NuovaAttivitaScreenState();
}

class _NuovaAttivitaScreenState extends State<NuovaAttivitaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titoloController;

  bool get _isEditing => widget.attivita != null;

  // Per default l'attività non è importante (requisito di dominio)
  bool _importante = false;
  bool _completata = false;

  @override
  void initState() {
    super.initState();
    _titoloController =
        TextEditingController(text: widget.attivita?.titolo ?? '');
    if (widget.attivita != null) {
      _importante = widget.attivita!.importante;
      _completata = widget.attivita!.completata;
    }
  }

  @override
  void dispose() {
    _titoloController.dispose();
    super.dispose();
  }

  void _confermaCreazione() {
    // Validazione del form: segnala errore se il titolo è mancante/vuoto
    if (_formKey.currentState!.validate()) {
      final attivitaRisultato = Attivita(
        id: widget.attivita?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        titolo: _titoloController.text.trim(),
        completata: _isEditing ? _completata : false,
        importante: _importante,
      );

      // Torna alla schermata precedente passando l'attività creata o modificata
      Navigator.of(context).pop(attivitaRisultato);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica Attività' : 'Nuova Attività'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          // Consente all'errore di scomparire non appena l'utente corregge il testo
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dettagli attività',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titoloController,
                        decoration: const InputDecoration(
                          labelText: 'Titolo *',
                          hintText: 'Cosa devi fare?',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit_note_outlined),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _confermaCreazione(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Il titolo è obbligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Contrassegna come importante'),
                        subtitle: Text(
                          _importante
                              ? 'Questa attività ha priorità elevata'
                              : 'Attività standard (non importante)',
                          style: TextStyle(
                            color: _importante
                                ? Colors.orange.shade800
                                : Colors.grey.shade600,
                          ),
                        ),
                        secondary: Icon(
                          _importante ? Icons.star : Icons.star_border,
                          color: _importante ? Colors.amber : Colors.grey,
                        ),
                        value: _importante,
                        onChanged: (bool value) {
                          setState(() {
                            _importante = value;
                          });
                        },
                      ),
                      if (_isEditing) ...[
                        const Divider(height: 24),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Stato completamento'),
                          subtitle: Text(
                            _completata
                                ? 'Attività completata'
                                : 'Attività da fare',
                            style: TextStyle(
                              color: _completata
                                  ? Colors.green.shade800
                                  : Colors.blue.shade800,
                            ),
                          ),
                          secondary: Icon(
                            _completata
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: _completata ? Colors.green : Colors.grey,
                          ),
                          value: _completata,
                          onChanged: (bool value) {
                            setState(() {
                              _completata = value;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                label:
                    Text(_isEditing ? 'Salva modifiche' : 'Aggiungi attività'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _confermaCreazione,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // Variante rinuncia: torna indietro senza confermare
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Annulla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
