import 'dart:convert';

class Attivita {
  final String id;
  String titolo;
  bool completata;
  bool importante;

  Attivita({
    required this.id,
    required this.titolo,
    this.completata = false,
    this.importante = false,
  });

  void toggleCompletata() {
    completata = !completata;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titolo': titolo,
      'completata': completata,
      'importante': importante,
    };
  }

  factory Attivita.fromMap(Map<String, dynamic> map) {
    return Attivita(
      id: map['id'] as String? ?? '',
      titolo: map['titolo'] as String? ?? '',
      completata: map['completata'] as bool? ?? false,
      importante: map['importante'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Attivita.fromJson(String source) =>
      Attivita.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
