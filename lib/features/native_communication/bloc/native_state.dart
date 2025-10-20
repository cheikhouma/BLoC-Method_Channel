/// États pour la communication native
import 'package:equatable/equatable.dart';

abstract class NativeState extends Equatable {
  const NativeState();

  @override
  List<Object?> get props => [];
}

/// État initial
class NativeInitial extends NativeState {
  const NativeInitial();
}

/// État de chargement
class NativeLoading extends NativeState {
  const NativeLoading();
}

/// État de succès avec données système
class SystemInfoLoaded extends NativeState {
  final String platform;
  final String version;
  final Map<String, dynamic> additionalInfo;

  const SystemInfoLoaded({
    required this.platform,
    required this.version,
    this.additionalInfo = const {},
  });

  @override
  List<Object?> get props => [platform, version, additionalInfo];
}

/// État de succès avec niveau de batterie
class BatteryLevelLoaded extends NativeState {
  final int level;
  final DateTime timestamp;

  const BatteryLevelLoaded({
    required this.level,
    required this.timestamp,
  });

  /// Retourne l'icône appropriée selon le niveau
  String get batteryIcon {
    if (level >= 90) return '🔋';
    if (level >= 50) return '🔋';
    if (level >= 20) return '🪫';
    return '🪫';
  }

  /// Retourne la couleur selon le niveau
  String get batteryColor {
    if (level >= 50) return 'green';
    if (level >= 20) return 'orange';
    return 'red';
  }

  @override
  List<Object?> get props => [level, timestamp];
}

/// État de succès avec données traitées
class NativeDataProcessed extends NativeState {
  final Map<String, dynamic> processedData;

  const NativeDataProcessed(this.processedData);

  @override
  List<Object?> get props => [processedData];
}

/// État d'écoute active des événements
class NativeEventStreamActive extends NativeState {
  final List<Map<String, dynamic>> events;

  const NativeEventStreamActive(this.events);

  @override
  List<Object?> get props => [events];
}

/// État d'erreur
class NativeError extends NativeState {
  final String message;
  final String? details;

  const NativeError(this.message, {this.details});

  @override
  List<Object?> get props => [message, details];
}
