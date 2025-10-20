package com.example.bloc_archi

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.concurrent.scheduleAtFixedRate

/**
 * MainActivity - Point d'entrée Android
 *
 * Cette classe démontre l'implémentation de Method Channels
 * pour la communication bidirectionnelle entre Flutter et Android
 */
class MainActivity : FlutterActivity() {
    // Nom du canal de méthodes (doit correspondre au code Flutter)
    private val METHOD_CHANNEL = "com.example.bloc_archi/native"
    private val EVENT_CHANNEL = "com.example.bloc_archi/native_events"

    private var timer: Timer? = null

    /**
     * Configuration du FlutterEngine
     *
     * Appelée une seule fois lors de l'initialisation du moteur Flutter
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Configuration du Method Channel
        setupMethodChannel(flutterEngine)

        // Configuration de l'Event Channel
        setupEventChannel(flutterEngine)
    }

    /**
     * Configuration du Method Channel
     *
     * Permet à Flutter d'appeler des méthodes Android
     */
    private fun setupMethodChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                // Récupérer les informations système
                "getSystemInfo" -> {
                    try {
                        val systemInfo = getSystemInfo()
                        result.success(systemInfo)
                    } catch (e: Exception) {
                        result.error("ERROR", "Erreur lors de la récupération des infos système", e.message)
                    }
                }

                // Récupérer le niveau de batterie
                "getBatteryLevel" -> {
                    try {
                        val batteryLevel = getBatteryLevel()
                        result.success(batteryLevel)
                    } catch (e: Exception) {
                        result.error("ERROR", "Erreur lors de la récupération du niveau de batterie", e.message)
                    }
                }

                // Traiter des données
                "processData" -> {
                    try {
                        val arguments = call.arguments as? Map<*, *>
                        val message = arguments?.get("message") as? String ?: ""
                        val count = arguments?.get("count") as? Int ?: 0

                        val processedData = processData(message, count)
                        result.success(processedData)
                    } catch (e: Exception) {
                        result.error("ERROR", "Erreur lors du traitement des données", e.message)
                    }
                }

                // Déclencher une action
                "triggerAction" -> {
                    try {
                        val arguments = call.arguments as? Map<*, *>
                        val action = arguments?.get("action") as? String ?: ""

                        // Implémentation de l'action (vibration, notification, etc.)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", "Erreur lors du déclenchement de l'action", e.message)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Configuration de l'Event Channel
     *
     * Permet d'envoyer un flux continu de données vers Flutter
     */
    private fun setupEventChannel(flutterEngine: FlutterEngine) {
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                // Démarrer l'envoi d'événements périodiques
                timer = Timer()
                timer?.scheduleAtFixedRate(0, 1000) {
                    val eventData = mapOf(
                        "type" to "sensor_update",
                        "value" to Random().nextInt(100),
                        "timestamp" to System.currentTimeMillis()
                    )
                    events?.success(eventData)
                }
            }

            override fun onCancel(arguments: Any?) {
                // Arrêter l'envoi d'événements
                timer?.cancel()
                timer = null
            }
        })
    }

    /**
     * Récupère les informations système Android
     *
     * @return Map contenant les informations système
     */
    private fun getSystemInfo(): Map<String, Any> {
        return mapOf(
            "platform" to "Android",
            "version" to Build.VERSION.RELEASE,
            "sdk" to Build.VERSION.SDK_INT,
            "manufacturer" to Build.MANUFACTURER,
            "model" to Build.MODEL,
            "device" to Build.DEVICE,
            "brand" to Build.BRAND
        )
    }

    /**
     * Récupère le niveau de batterie
     *
     * @return Niveau de batterie en pourcentage (0-100)
     */
    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    /**
     * Traite des données reçues depuis Flutter
     *
     * Exemple de traitement natif de données
     *
     * @param message Message à traiter
     * @param count Nombre à traiter
     * @return Map contenant les données traitées
     */
    private fun processData(message: String, count: Int): Map<String, Any> {
        // Simulation de traitement natif
        val processedMessage = message.uppercase(Locale.getDefault())
        val processedCount = count * 2

        return mapOf(
            "originalMessage" to message,
            "processedMessage" to processedMessage,
            "originalCount" to count,
            "processedCount" to processedCount,
            "timestamp" to System.currentTimeMillis(),
            "processedBy" to "Android Native Code"
        )
    }

    override fun onDestroy() {
        timer?.cancel()
        super.onDestroy()
    }
}
