/// Classe abstraite de base pour tous les BLoCs
///
/// Cette classe définit la structure commune que tous les BLoCs
/// doivent suivre dans l'application.
///
/// Utilisation de génériques :
/// - [Event] : Type des événements que le BLoC peut recevoir
/// - [State] : Type des états que le BLoC peut émettre
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC abstrait de base
///
/// Exemple d'utilisation :
/// ```dart
/// class MyBloc extends BaseBloc<MyEvent, MyState> {
///   MyBloc() : super(MyInitialState()) {
///     on<MyEvent>(_onMyEvent);
///   }
/// }
/// ```
abstract class BaseBloc<E, S> extends Bloc<E, S> {
  BaseBloc(S initialState) : super(initialState);

  /// Méthode appelée lors de la création du BLoC
  @override
  void onEvent(E event) {
    super.onEvent(event);
    logEvent(event);
  }

  /// Méthode appelée lors d'un changement d'état
  @override
  void onChange(Change<S> change) {
    super.onChange(change);
    logStateChange(change);
  }

  /// Méthode appelée lors d'une erreur
  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    logError(error, stackTrace);
  }

  /// Log des événements (utile pour le débogage)
  void logEvent(E event) {
    print('🔵 [${runtimeType}] Event: $event');
  }

  /// Log des changements d'état (utile pour le débogage)
  void logStateChange(Change<S> change) {
    print('🟢 [${runtimeType}] State Change: ${change.currentState} → ${change.nextState}');
  }

  /// Log des erreurs
  void logError(Object error, StackTrace stackTrace) {
    print('🔴 [${runtimeType}] Error: $error');
    print('StackTrace: $stackTrace');
  }
}
