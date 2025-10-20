/// Gestion des Method Channels pour la communication avec le code natif
///
/// Les Method Channels permettent la communication bidirectionnelle entre
/// Flutter et le code natif (Android/iOS)
import 'package:flutter/services.dart';

/// Service de communication avec les plateformes natives
///
/// Ce service encapsule la logique de communication avec le code natif
/// via les Method Channels de Flutter
class PlatformChannelService {
  /// Canal de communication avec la plateforme native
  ///
  /// Le nom du canal doit être identique côté natif (Android/iOS)
  static const MethodChannel _channel = MethodChannel('com.example.bloc_archi/native');

  /// Canal d'événements pour recevoir des données natives en continu
  static const EventChannel _eventChannel = EventChannel('com.example.bloc_archi/native_events');

  /// Obtenir des informations système depuis le code natif
  ///
  /// Exemple Android (MainActivity.kt) :
  /// ```kotlin
  /// MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.bloc_archi/native")
  ///   .setMethodCallHandler { call, result ->
  ///     when (call.method) {
  ///       "getSystemInfo" -> {
  ///         val info = mapOf(
  ///           "platform" to "Android",
  ///           "version" to Build.VERSION.RELEASE
  ///         )
  ///         result.success(info)
  ///       }
  ///     }
  ///   }
  /// ```
  ///
  /// Exemple iOS (AppDelegate.swift) :
  /// ```swift
  /// let channel = FlutterMethodChannel(
  ///   name: "com.example.bloc_archi/native",
  ///   binaryMessenger: controller.binaryMessenger
  /// )
  /// channel.setMethodCallHandler { (call, result) in
  ///   if call.method == "getSystemInfo" {
  ///     result([
  ///       "platform": "iOS",
  ///       "version": UIDevice.current.systemVersion
  ///     ])
  ///   }
  /// }
  /// ```
  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getSystemInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print("Erreur lors de l'appel natif: ${e.message}");
      return {
        'platform': 'Unknown',
        'version': 'N/A',
        'error': e.message,
      };
    }
  }

  /// Obtenir le niveau de batterie depuis le code natif
  ///
  /// Exemple Android :
  /// ```kotlin
  /// "getBatteryLevel" -> {
  ///   val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
  ///   val batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
  ///   result.success(batteryLevel)
  /// }
  /// ```
  ///
  /// Exemple iOS :
  /// ```swift
  /// if call.method == "getBatteryLevel" {
  ///   UIDevice.current.isBatteryMonitoringEnabled = true
  ///   let batteryLevel = UIDevice.current.batteryLevel
  ///   result(Int(batteryLevel * 100))
  /// }
  /// ```
  Future<int> getBatteryLevel() async {
    try {
      final int result = await _channel.invokeMethod('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      print("Impossible de récupérer le niveau de batterie: ${e.message}");
      return -1;
    }
  }

  /// Envoyer des données complexes au code natif
  ///
  /// Exemple Android :
  /// ```kotlin
  /// "processData" -> {
  ///   val data = call.arguments as Map<String, Any>
  ///   val message = data["message"] as String
  ///   val count = data["count"] as Int
  ///
  ///   // Traitement natif
  ///   val processedData = mapOf(
  ///     "originalMessage" to message,
  ///     "processedCount" to count * 2,
  ///     "timestamp" to System.currentTimeMillis()
  ///   )
  ///   result.success(processedData)
  /// }
  /// ```
  Future<Map<String, dynamic>> processData({
    required String message,
    required int count,
  }) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'processData',
        {
          'message': message,
          'count': count,
        },
      );
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print("Erreur lors du traitement des données: ${e.message}");
      return {'error': e.message};
    }
  }

  /// Écouter des événements natifs en continu
  ///
  /// Exemple Android :
  /// ```kotlin
  /// EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.bloc_archi/native_events")
  ///   .setStreamHandler(object : EventChannel.StreamHandler {
  ///     override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
  ///       // Envoyer des événements périodiquement
  ///       timer = Timer.scheduleAtFixedRate(object : TimerTask() {
  ///         override fun run() {
  ///           events?.success(mapOf(
  ///             "type" to "sensor_update",
  ///             "value" to Random.nextInt(100)
  ///           ))
  ///         }
  ///       }, 0, 1000)
  ///     }
  ///   })
  /// ```
  ///
  /// Exemple iOS :
  /// ```swift
  /// let eventChannel = FlutterEventChannel(
  ///   name: "com.example.bloc_archi/native_events",
  ///   binaryMessenger: controller.binaryMessenger
  /// )
  /// eventChannel.setStreamHandler(MyStreamHandler())
  /// ```
  Stream<Map<String, dynamic>> listenToNativeEvents() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }

  /// Appeler une méthode native sans retour
  ///
  /// Utile pour déclencher des actions natives (vibration, notification, etc.)
  Future<void> triggerNativeAction(String action) async {
    try {
      await _channel.invokeMethod('triggerAction', {'action': action});
    } on PlatformException catch (e) {
      print("Erreur lors du déclenchement de l'action: ${e.message}");
    }
  }
}
