/// Événements du Counter BLoC
///
/// Les événements représentent les actions utilisateur ou système
/// qui déclenchent des changements d'état
import 'package:equatable/equatable.dart';

/// Classe abstraite de base pour tous les événements du compteur
///
/// Utilisation de Equatable pour comparer les événements
/// (utile pour éviter les rebuilds inutiles)
abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object?> get props => [];
}

/// Événement : Incrémenter le compteur
///
/// Déclenché lorsque l'utilisateur appuie sur le bouton "+"
class CounterIncremented extends CounterEvent {
  const CounterIncremented();

  @override
  String toString() => 'CounterIncremented';
}

/// Événement : Décrémenter le compteur
///
/// Déclenché lorsque l'utilisateur appuie sur le bouton "-"
class CounterDecremented extends CounterEvent {
  const CounterDecremented();

  @override
  String toString() => 'CounterDecremented';
}

/// Événement : Réinitialiser le compteur
///
/// Remet le compteur à zéro
class CounterReset extends CounterEvent {
  const CounterReset();

  @override
  String toString() => 'CounterReset';
}

/// Événement : Définir une valeur spécifique
///
/// Permet de définir directement une valeur pour le compteur
class CounterValueSet extends CounterEvent {
  final int value;

  const CounterValueSet(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'CounterValueSet { value: $value }';
}
