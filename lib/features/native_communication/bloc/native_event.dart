/// Événements pour la communication native
import 'package:equatable/equatable.dart';

abstract class NativeEvent extends Equatable {
  const NativeEvent();

  @override
  List<Object?> get props => [];
}

/// Événement : Charger les informations système
class LoadSystemInfo extends NativeEvent {
  const LoadSystemInfo();
}

/// Événement : Charger le niveau de batterie
class LoadBatteryLevel extends NativeEvent {
  const LoadBatteryLevel();
}

/// Événement : Traiter des données avec le code natif
class ProcessNativeData extends NativeEvent {
  final String message;
  final int count;

  const ProcessNativeData({
    required this.message,
    required this.count,
  });

  @override
  List<Object?> get props => [message, count];
}

/// Événement : Démarrer l'écoute des événements natifs
class StartNativeEventStream extends NativeEvent {
  const StartNativeEventStream();
}

/// Événement : Arrêter l'écoute des événements natifs
class StopNativeEventStream extends NativeEvent {
  const StopNativeEventStream();
}

/// Événement : Réception d'un événement natif
class NativeEventReceived extends NativeEvent {
  final Map<String, dynamic> data;

  const NativeEventReceived(this.data);

  @override
  List<Object?> get props => [data];
}
