/// États du Counter BLoC
///
/// Les états représentent les différentes situations dans lesquelles
/// l'interface utilisateur peut se trouver
import 'package:equatable/equatable.dart';

/// Classe abstraite de base pour tous les états du compteur
///
/// Utilisation de Equatable pour comparer les états
/// Flutter ne reconstruit l'UI que si l'état change réellement
abstract class CounterState extends Equatable {
  const CounterState();

  @override
  List<Object?> get props => [];
}

/// État : Valeur du compteur
///
/// Contient la valeur actuelle du compteur et des métadonnées
class CounterValue extends CounterState {
  /// Valeur actuelle du compteur
  final int value;

  /// Indique si le compteur est à sa valeur maximale
  final bool isAtMax;

  /// Indique si le compteur est à sa valeur minimale
  final bool isAtMin;

  /// Horodatage de la dernière modification
  final DateTime lastUpdated;

  const CounterValue({
    required this.value,
    this.isAtMax = false,
    this.isAtMin = false,
    required this.lastUpdated,
  });

  /// État initial du compteur
  factory CounterValue.initial() {
    return CounterValue(
      value: 0,
      isAtMin: true,
      lastUpdated: DateTime.now(),
    );
  }

  /// Copie de l'état avec modifications
  ///
  /// Pattern utilisé pour créer un nouvel état basé sur l'ancien
  /// (principe d'immutabilité)
  CounterValue copyWith({
    int? value,
    bool? isAtMax,
    bool? isAtMin,
    DateTime? lastUpdated,
  }) {
    return CounterValue(
      value: value ?? this.value,
      isAtMax: isAtMax ?? this.isAtMax,
      isAtMin: isAtMin ?? this.isAtMin,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [value, isAtMax, isAtMin, lastUpdated];

  @override
  String toString() =>
      'CounterValue { value: $value, isAtMax: $isAtMax, isAtMin: $isAtMin }';
}

/// État : Chargement
///
/// Utilisé lorsqu'une opération asynchrone est en cours
class CounterLoading extends CounterState {
  const CounterLoading();

  @override
  String toString() => 'CounterLoading';
}

/// État : Erreur
///
/// Utilisé lorsqu'une erreur se produit
class CounterError extends CounterState {
  final String message;

  const CounterError(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'CounterError { message: $message }';
}
