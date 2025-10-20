/// Counter BLoC - Gestion de la logique métier du compteur
///
/// Ce BLoC gère toute la logique du compteur :
/// - Incrémentation
/// - Décrémentation
/// - Réinitialisation
/// - Validation des limites
library;

import 'package:bloc_archi/core/blocs/base_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'counter_event.dart';
import 'counter_state.dart';

/// BLoC du compteur
///
/// Architecture :
/// Event → BLoC → State → UI
///
/// Le BLoC reçoit des événements, traite la logique métier,
/// et émet de nouveaux états vers l'interface utilisateur
class CounterBloc extends BaseBloc<CounterEvent, CounterState> {
  /// Valeur maximale autorisée
  static const int maxValue = 100;

  /// Valeur minimale autorisée
  static const int minValue = 0;

  /// Constructeur
  ///
  /// Initialise le BLoC avec l'état initial et enregistre
  /// les gestionnaires d'événements
  CounterBloc() : super(CounterValue.initial()) {
    // Enregistrement des gestionnaires d'événements
    on<CounterIncremented>(_onIncremented);
    on<CounterDecremented>(_onDecremented);
    on<CounterReset>(_onReset);
    on<CounterValueSet>(_onValueSet);
  }

  /// Gestionnaire : Incrémenter le compteur
  ///
  /// Logique :
  /// 1. Récupère la valeur actuelle
  /// 2. Vérifie qu'on ne dépasse pas la limite max
  /// 3. Émet un nouvel état avec la nouvelle valeur
  Future<void> _onIncremented(
    CounterIncremented event,
    Emitter<CounterState> emit,
  ) async {
    final currentState = state;

    if (currentState is CounterValue) {
      final newValue = currentState.value + 1;

      // Vérification de la limite maximale
      if (newValue > maxValue) {
        emit(const CounterError('Valeur maximale atteinte'));
        // Retour à l'état précédent après 2 secondes
        await Future.delayed(const Duration(seconds: 2));
        emit(currentState);
        return;
      }

      // Émission du nouvel état
      emit(
        currentState.copyWith(
          value: newValue,
          isAtMax: newValue >= maxValue,
          isAtMin: false,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  /// Gestionnaire : Décrémenter le compteur
  ///
  /// Logique similaire à l'incrémentation mais en sens inverse
  Future<void> _onDecremented(
    CounterDecremented event,
    Emitter<CounterState> emit,
  ) async {
    final currentState = state;

    if (currentState is CounterValue) {
      final newValue = currentState.value - 1;

      // Vérification de la limite minimale
      if (newValue < minValue) {
        emit(const CounterError('Valeur minimale atteinte'));
        await Future.delayed(const Duration(seconds: 2));
        emit(currentState);
        return;
      }

      emit(
        currentState.copyWith(
          value: newValue,
          isAtMin: newValue <= minValue,
          isAtMax: false,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  /// Gestionnaire : Réinitialiser le compteur
  ///
  /// Remet le compteur à sa valeur initiale (0)
  void _onReset(CounterReset event, Emitter<CounterState> emit) {
    emit(CounterValue.initial());
  }

  /// Gestionnaire : Définir une valeur spécifique
  ///
  /// Permet de définir directement une valeur
  /// avec validation des limites
  void _onValueSet(CounterValueSet event, Emitter<CounterState> emit) {
    final currentState = state;

    if (currentState is CounterValue) {
      // Validation de la valeur
      if (event.value < minValue || event.value > maxValue) {
        emit(
          CounterError(
            'Valeur invalide. Doit être entre $minValue et $maxValue',
          ),
        );
        return;
      }

      emit(
        currentState.copyWith(
          value: event.value,
          isAtMax: event.value >= maxValue,
          isAtMin: event.value <= minValue,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }
}
