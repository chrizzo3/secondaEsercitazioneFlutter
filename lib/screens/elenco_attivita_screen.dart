import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attivita.dart';
import 'nuova_attivita_screen.dart';

class ElencoAttivitaScreen extends StatefulWidget {
  const ElencoAttivitaScreen({super.key});

  @override
  State<ElencoAttivitaScreen> createState() => _ElencoAttivitaScreenState();
}

class _ElencoAttivitaScreenState extends State<ElencoAttivitaScreen> {
  static const String _storageKey = 'elenco_attivita_key';
  final List<Attivita> _attivitaList = [];

  @override
  void initState() {
    super.initState();
    _caricaAttivita();
  }

  Future<void> _caricaAttivita() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null && mounted) {
        final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
        setState(() {
          _attivitaList.clear();
          _attivitaList.addAll(
            jsonList.map((item) => Attivita.fromMap(item as Map<String, dynamic>)),
          );
        });
      }
    } catch (e) {
      debugPrint('Errore nel caricamento delle attività: $e');
    }
  }

  Future<void> _salvaAttivita() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(
        _attivitaList.map((attivita) => attivita.toMap()).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Errore nel salvataggio delle attività: $e');
    }
  }

  int get _completateCount =>
      _attivitaList.where((att) => att.completata).length;

  int get _totaleCount => _attivitaList.length;

  Future<void> _navigaNuovaAttivita() async {
    final nuovaAttivita = await Navigator.of(context).push<Attivita>(
      MaterialPageRoute(
        builder: (context) => const NuovaAttivitaScreen(),
      ),
    );

    if (nuovaAttivita != null && mounted) {
      setState(() {
        _attivitaList.add(nuovaAttivita);
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attività "${nuovaAttivita.titolo}" aggiunta con successo!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      _salvaAttivita();
    }
  }

  Future<void> _navigaModificaAttivita(Attivita attivita) async {
    final attivitaModificata = await Navigator.of(context).push<Attivita>(
      MaterialPageRoute(
        builder: (context) => NuovaAttivitaScreen(attivita: attivita),
      ),
    );

    if (attivitaModificata != null && mounted) {
      setState(() {
        final index =
            _attivitaList.indexWhere((a) => a.id == attivitaModificata.id);
        if (index != -1) {
          _attivitaList[index] = attivitaModificata;
        }
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Attività "${attivitaModificata.titolo}" modificata con successo!',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      _salvaAttivita();
    }
  }

  void _toggleStato(Attivita attivita) {
    setState(() {
      attivita.toggleCompletata();
    });
    _salvaAttivita();
  }

  Future<void> _confermaEliminazione(Attivita attivita) async {
    final bool? confermato = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Conferma eliminazione'),
          content: Text(
            'Sei sicuro di voler eliminare l\'attività "${attivita.titolo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Annulla'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (confermato == true && mounted) {
      setState(() {
        _attivitaList.remove(attivita);
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attività "${attivita.titolo}" eliminata.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      _salvaAttivita();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildRiepilogo(theme),

          Expanded(
            child: _attivitaList.isEmpty
                ? _buildEmptyState(theme)
                : _buildListaAttivita(theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigaNuovaAttivita,
        icon: const Icon(Icons.add),
        label: const Text('Nuova attività'),
      ),
    );
  }

  Widget _buildRiepilogo(ThemeData theme) {
    final double progresso =
        _totaleCount > 0 ? (_completateCount / _totaleCount) : 0.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attività completate',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _completateCount == _totaleCount && _totaleCount > 0
                      ? Colors.green.withValues(alpha: 0.2)
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_completateCount su $_totaleCount',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _completateCount == _totaleCount && _totaleCount > 0
                        ? Colors.green.shade800
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _completateCount == _totaleCount && _totaleCount > 0
                    ? Colors.green
                    : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_rounded,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 20),
            Text(
              'Nessuna attività presente',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tocca il pulsante "+ Nuova attività" in basso per aggiungerne una.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaAttivita(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _attivitaList.length,
      itemBuilder: (context, index) {
        final attivita = _attivitaList[index];
        return _buildAttivitaCard(theme, attivita);
      },
    );
  }

  Widget _buildAttivitaCard(ThemeData theme, Attivita attivita) {
    return Card(
      key: ValueKey(attivita.id),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: attivita.importante
              ? Colors.amber.shade700
              : theme.colorScheme.outlineVariant,
          width: attivita.importante ? 1.8 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _toggleStato(attivita),
        onLongPress: () => _navigaModificaAttivita(attivita),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Checkbox(
                value: attivita.completata,
                activeColor: Colors.green,
                onChanged: (_) => _toggleStato(attivita),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attivita.titolo,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: attivita.completata
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: attivita.completata
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            attivita.completata ? 'Completata' : 'Da fare',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: attivita.completata
                                  ? Colors.green.shade800
                                  : Colors.blue.shade800,
                            ),
                          ),
                        ),

                        if (attivita.importante) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Colors.amber.shade900,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Importante',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: theme.colorScheme.primary,
                tooltip: 'Modifica attività',
                onPressed: () => _navigaModificaAttivita(attivita),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: theme.colorScheme.error,
                tooltip: 'Elimina attività',
                onPressed: () => _confermaEliminazione(attivita),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
