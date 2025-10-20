/// BLoC pour la communication avec le code natif
///
/// Gère les interactions avec les Method Channels
import 'dart:async';
import 'package:bloc_archi/core/blocs/base_bloc.dart';
import 'package:bloc_archi/core/channels/platform_channel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'native_event.dart';
import 'native_state.dart';

class NativeBloc extends BaseBloc<NativeEvent, NativeState> {
  final PlatformChannelService _channelService;
  StreamSubscription? _eventSubscription;

  NativeBloc({PlatformChannelService? channelService})
    : _channelService = channelService ?? PlatformChannelService(),
      super(const NativeInitial()) {
    on<LoadSystemInfo>(_onLoadSystemInfo);
    on<LoadBatteryLevel>(_onLoadBatteryLevel);
    on<ProcessNativeData>(_onProcessNativeData);
    on<StartNativeEventStream>(_onStartNativeEventStream);
    on<StopNativeEventStream>(_onStopNativeEventStream);
    on<NativeEventReceived>(_onNativeEventReceived);
  }

  /// Charge les informations système depuis le code natif
  Future<void> _onLoadSystemInfo(
    LoadSystemInfo event,
    Emitter<NativeState> emit,
  ) async {
    try {
      emit(const NativeLoading());

      // Appel au code natif via Method Channel
      final systemInfo = await _channelService.getSystemInfo();

      emit(
        SystemInfoLoaded(
          platform: systemInfo['platform'] ?? 'Unknown',
          version: systemInfo['version'] ?? 'N/A',
          additionalInfo: Map<String, dynamic>.from(systemInfo)
            ..remove('platform')
            ..remove('version'),
        ),
      );
    } catch (e) {
      emit(
        NativeError(
          'Erreur lors du chargement des informations système',
          details: e.toString(),
        ),
      );
    }
  }

  /// Charge le niveau de batterie
  Future<void> _onLoadBatteryLevel(
    LoadBatteryLevel event,
    Emitter<NativeState> emit,
  ) async {
    try {
      emit(const NativeLoading());

      // Appel au code natif
      final batteryLevel = await _channelService.getBatteryLevel();

      if (batteryLevel < 0) {
        emit(
          const NativeError('Impossible de récupérer le niveau de batterie'),
        );
        return;
      }

      emit(BatteryLevelLoaded(level: batteryLevel, timestamp: DateTime.now()));
    } catch (e) {
      emit(
        NativeError(
          'Erreur lors de la récupération du niveau de batterie',
          details: e.toString(),
        ),
      );
    }
  }

  /// Traite des données avec le code natif
  Future<void> _onProcessNativeData(
    ProcessNativeData event,
    Emitter<NativeState> emit,
  ) async {
    try {
      emit(const NativeLoading());

      // Envoi de données au code natif et réception du résultat
      final result = await _channelService.processData(
        message: event.message,
        count: event.count,
      );

      emit(NativeDataProcessed(result));
    } catch (e) {
      emit(
        NativeError(
          'Erreur lors du traitement des données',
          details: e.toString(),
        ),
      );
    }
  }

  /// Démarre l'écoute des événements natifs
  Future<void> _onStartNativeEventStream(
    StartNativeEventStream event,
    Emitter<NativeState> emit,
  ) async {
    try {
      // Annule l'abonnement précédent si existant
      await _eventSubscription?.cancel();

      // Écoute du stream d'événements natifs
      _eventSubscription = _channelService.listenToNativeEvents().listen(
        (eventData) {
          // Envoie chaque événement reçu au BLoC
          add(NativeEventReceived(eventData));
        },
        onError: (error) {
          emit(
            NativeError(
              'Erreur dans le stream d\'événements',
              details: error.toString(),
            ),
          );
        },
      );

      emit(const NativeEventStreamActive([]));
    } catch (e) {
      emit(
        NativeError(
          'Erreur lors du démarrage du stream',
          details: e.toString(),
        ),
      );
    }
  }

  /// Arrête l'écoute des événements natifs
  Future<void> _onStopNativeEventStream(
    StopNativeEventStream event,
    Emitter<NativeState> emit,
  ) async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    emit(const NativeInitial());
  }

  /// Gère la réception d'un événement natif
  void _onNativeEventReceived(
    NativeEventReceived event,
    Emitter<NativeState> emit,
  ) {
    final currentState = state;

    // Accumule les événements reçus
    if (currentState is NativeEventStreamActive) {
      final updatedEvents = List<Map<String, dynamic>>.from(currentState.events)
        ..add(event.data);

      // Garde seulement les 10 derniers événements
      if (updatedEvents.length > 10) {
        updatedEvents.removeAt(0);
      }

      emit(NativeEventStreamActive(updatedEvents));
    } else {
      emit(NativeEventStreamActive([event.data]));
    }
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }
}
