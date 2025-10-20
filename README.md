# Architecture BLoC & Method Channels - Projet de Démonstration

> **Contexte** : Migration d'une application native vers Flutter pour garantir la maintenabilité et l'interopérabilité

Ce projet Flutter démontre concrètement l'implémentation de deux concepts fondamentaux abordés dans le rapport de stage :

1. **Architecture BLoC** - Pattern de gestion d'état
2. **Method Channels** - Communication Flutter ↔ Code natif (Android/iOS)

---

## 📋 Table des matières

- [Architecture du Projet](#architecture-du-projet)
- [Architecture BLoC](#architecture-bloc)
- [Method Channels](#method-channels)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Structure des Fichiers](#structure-des-fichiers)
- [Ressources](#ressources)

---

## 🏗️ Architecture du Projet

```
lib/
├── core/
│   ├── blocs/
│   │   └── base_bloc.dart           # BLoC abstrait de base
│   └── channels/
│       └── platform_channel.dart    # Service Method Channels
├── features/
│   ├── counter/                     # Feature : Compteur (BLoC)
│   │   ├── bloc/
│   │   │   ├── counter_bloc.dart    # Logique métier
│   │   │   ├── counter_event.dart   # Événements
│   │   │   └── counter_state.dart   # États
│   │   └── view/
│   │       └── counter_page.dart    # Interface utilisateur
│   └── native_communication/        # Feature : Communication native
│       ├── bloc/
│       │   ├── native_bloc.dart
│       │   ├── native_event.dart
│       │   └── native_state.dart
│       └── view/
│           └── native_page.dart
└── main.dart                        # Point d'entrée

android/
└── app/src/main/kotlin/.../MainActivity.kt  # Code natif Android

ios/
└── Runner/AppDelegate.swift                  # Code natif iOS
```

---

## 🔵 Architecture BLoC

### Qu'est-ce que le pattern BLoC ?

**BLoC (Business Logic Component)** est un pattern de gestion d'état qui sépare :
- La **logique métier** (BLoC)
- L'**interface utilisateur** (UI/Widgets)
- Les **données** (Models)

### Principe de fonctionnement

```
┌─────────────┐      Events      ┌──────────┐      States      ┌─────────────┐
│             │ ───────────────> │          │ ───────────────> │             │
│  UI/Widget  │                  │   BLoC   │                  │  UI Update  │
│             │ <─────────────── │          │ <─────────────── │             │
└─────────────┘     Streams      └──────────┘      Rebuild     └─────────────┘
```

### Les 3 composants principaux

#### 1. Events (Événements)

Les événements représentent les **actions utilisateur** ou **événements système**.

```dart
// lib/features/counter/bloc/counter_event.dart

abstract class CounterEvent extends Equatable {
  const CounterEvent();
}

class CounterIncremented extends CounterEvent {
  const CounterIncremented();
}

class CounterDecremented extends CounterEvent {
  const CounterDecremented();
}

class CounterReset extends CounterEvent {
  const CounterReset();
}
```

**Pourquoi Equatable ?**
- Permet la comparaison automatique des événements
- Évite les rebuilds inutiles de l'UI
- Facilite les tests unitaires

#### 2. States (États)

Les états représentent les **différentes situations** de l'interface.

```dart
// lib/features/counter/bloc/counter_state.dart

abstract class CounterState extends Equatable {
  const CounterState();
}

// État avec valeur
class CounterValue extends CounterState {
  final int value;
  final bool isAtMax;
  final bool isAtMin;
  final DateTime lastUpdated;

  const CounterValue({
    required this.value,
    this.isAtMax = false,
    this.isAtMin = false,
    required this.lastUpdated,
  });

  // Pattern copyWith pour l'immutabilité
  CounterValue copyWith({
    int? value,
    bool? isAtMax,
    bool? isAtMin,
  }) {
    return CounterValue(
      value: value ?? this.value,
      isAtMax: isAtMax ?? this.isAtMax,
      isAtMin: isAtMin ?? this.isAtMin,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [value, isAtMax, isAtMin, lastUpdated];
}

// État d'erreur
class CounterError extends CounterState {
  final String message;
  const CounterError(this.message);

  @override
  List<Object?> get props => [message];
}
```

**Concepts clés :**
- **Immutabilité** : Les états ne sont jamais modifiés, on en crée de nouveaux
- **Pattern copyWith** : Crée une copie avec certains champs modifiés
- **Équatabilité** : Comparaison automatique des états

#### 3. BLoC (Logique métier)

Le BLoC reçoit les événements et émet des états.

```dart
// lib/features/counter/bloc/counter_bloc.dart

class CounterBloc extends BaseBloc<CounterEvent, CounterState> {
  static const int maxValue = 100;
  static const int minValue = 0;

  CounterBloc() : super(CounterValue.initial()) {
    // Enregistrement des gestionnaires
    on<CounterIncremented>(_onIncremented);
    on<CounterDecremented>(_onDecremented);
    on<CounterReset>(_onReset);
  }

  // Gestionnaire d'événement
  Future<void> _onIncremented(
    CounterIncremented event,
    Emitter<CounterState> emit,
  ) async {
    final currentState = state;

    if (currentState is CounterValue) {
      final newValue = currentState.value + 1;

      // Validation
      if (newValue > maxValue) {
        emit(const CounterError('Valeur maximale atteinte'));
        await Future.delayed(const Duration(seconds: 2));
        emit(currentState); // Retour à l'état précédent
        return;
      }

      // Émission du nouvel état
      emit(currentState.copyWith(
        value: newValue,
        isAtMax: newValue >= maxValue,
        isAtMin: false,
      ));
    }
  }

  void _onReset(CounterReset event, Emitter<CounterState> emit) {
    emit(CounterValue.initial());
  }
}
```

**Points clés :**
- `on<Event>()` : Enregistre un gestionnaire pour un type d'événement
- `emit()` : Émet un nouvel état
- `Emitter` : Permet d'émettre plusieurs états (async)
- Validation de la logique métier dans le BLoC

### Utilisation dans l'UI

```dart
// lib/features/counter/view/counter_page.dart

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // 1. Fournir le BLoC
      create: (context) => CounterBloc(),
      child: CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 2. Écouter les changements d'état (pour les side-effects)
          BlocListener<CounterBloc, CounterState>(
            listener: (context, state) {
              if (state is CounterError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: SizedBox.shrink(),
          ),

          // 3. Reconstruire l'UI selon l'état
          BlocBuilder<CounterBloc, CounterState>(
            builder: (context, state) {
              if (state is CounterValue) {
                return Text('${state.value}');
              }
              return Text('État inconnu');
            },
          ),

          // 4. Envoyer des événements
          FloatingActionButton(
            onPressed: () {
              context.read<CounterBloc>().add(CounterIncremented());
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
```

**Widgets BLoC importants :**
- `BlocProvider` : Fournit le BLoC aux widgets enfants
- `BlocBuilder` : Reconstruit l'UI quand l'état change
- `BlocListener` : Exécute du code (side-effects) quand l'état change
- `context.read<T>()` : Accède au BLoC pour envoyer des événements

### Avantages de BLoC

✅ **Séparation des responsabilités**
- UI ≠ Logique métier
- Facilite la maintenance

✅ **Testabilité**
- Tests unitaires faciles (BLoC isolé)
- Tests de widgets simplifiés

✅ **Réutilisabilité**
- BLoC utilisable dans plusieurs écrans
- Logique métier indépendante de l'UI

✅ **Prédictibilité**
- Flux de données unidirectionnel
- États immutables

---

## 🟢 Method Channels

### Qu'est-ce qu'un Method Channel ?

Les **Method Channels** permettent la communication **bidirectionnelle** entre :
- Le code **Dart/Flutter**
- Le code **natif** (Kotlin/Swift)

### Principe de fonctionnement

```
┌──────────────────┐                    ┌──────────────────┐
│                  │   invokeMethod()   │                  │
│  Flutter (Dart)  │ ─────────────────> │  Native Code     │
│                  │                    │  (Kotlin/Swift)  │
│                  │ <───────────────── │                  │
│                  │      Result        │                  │
└──────────────────┘                    └──────────────────┘
```

### Implémentation côté Flutter

```dart
// lib/core/channels/platform_channel.dart

import 'package:flutter/services.dart';

class PlatformChannelService {
  // Nom du canal (doit être identique côté natif)
  static const MethodChannel _channel =
      MethodChannel('com.example.bloc_archi/native');

  /// Obtenir les informations système
  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('getSystemInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print("Erreur: ${e.message}");
      return {'error': e.message};
    }
  }

  /// Obtenir le niveau de batterie
  Future<int> getBatteryLevel() async {
    try {
      final int result = await _channel.invokeMethod('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      print("Erreur: ${e.message}");
      return -1;
    }
  }

  /// Envoyer des données au code natif
  Future<Map<String, dynamic>> processData({
    required String message,
    required int count,
  }) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'processData',
        {'message': message, 'count': count},
      );
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      return {'error': e.message};
    }
  }
}
```

**Points clés :**
- `MethodChannel` : Canal de communication
- `invokeMethod()` : Appelle une méthode native
- `PlatformException` : Gestion des erreurs natives
- Typage strict des données échangées

### Implémentation côté Android (Kotlin)

```kotlin
// android/app/src/main/kotlin/.../MainActivity.kt

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.BatteryManager
import android.os.Build

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.bloc_archi/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSystemInfo" -> {
                    val systemInfo = mapOf(
                        "platform" to "Android",
                        "version" to Build.VERSION.RELEASE,
                        "sdk" to Build.VERSION.SDK_INT,
                        "manufacturer" to Build.MANUFACTURER,
                        "model" to Build.MODEL
                    )
                    result.success(systemInfo)
                }

                "getBatteryLevel" -> {
                    val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
                    val level = batteryManager.getIntProperty(
                        BatteryManager.BATTERY_PROPERTY_CAPACITY
                    )
                    result.success(level)
                }

                "processData" -> {
                    val args = call.arguments as? Map<*, *>
                    val message = args?.get("message") as? String ?: ""
                    val count = args?.get("count") as? Int ?: 0

                    val processedData = mapOf(
                        "originalMessage" to message,
                        "processedMessage" to message.uppercase(),
                        "processedCount" to count * 2,
                        "timestamp" to System.currentTimeMillis()
                    )
                    result.success(processedData)
                }

                else -> result.notImplemented()
            }
        }
    }
}
```

**Éléments importants :**
- `setMethodCallHandler` : Écoute les appels depuis Flutter
- `call.method` : Nom de la méthode appelée
- `call.arguments` : Paramètres envoyés depuis Flutter
- `result.success()` : Renvoie le résultat à Flutter
- `result.error()` : Renvoie une erreur
- `result.notImplemented()` : Méthode non implémentée

### Implémentation côté iOS (Swift)

```swift
// ios/Runner/AppDelegate.swift

import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "com.example.bloc_archi/native",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { (call, result) in
            switch call.method {
            case "getSystemInfo":
                let systemInfo: [String: Any] = [
                    "platform": "iOS",
                    "version": UIDevice.current.systemVersion,
                    "model": UIDevice.current.model,
                    "name": UIDevice.current.name
                ]
                result(systemInfo)

            case "getBatteryLevel":
                UIDevice.current.isBatteryMonitoringEnabled = true
                let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
                result(batteryLevel)

            case "processData":
                if let args = call.arguments as? [String: Any],
                   let message = args["message"] as? String,
                   let count = args["count"] as? Int {
                    let processed: [String: Any] = [
                        "originalMessage": message,
                        "processedMessage": message.uppercased(),
                        "processedCount": count * 2,
                        "timestamp": Date().timeIntervalSince1970
                    ]
                    result(processed)
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

### Event Channels (flux continu)

Pour des **flux continus de données** (capteurs, localisation, etc.) :

```dart
// Flutter
static const EventChannel _eventChannel =
    EventChannel('com.example.bloc_archi/native_events');

Stream<Map<String, dynamic>> listenToNativeEvents() {
  return _eventChannel.receiveBroadcastStream().map((event) {
    return Map<String, dynamic>.from(event as Map);
  });
}
```

```kotlin
// Android
EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
    .setStreamHandler(object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            timer = Timer()
            timer?.scheduleAtFixedRate(0, 1000) {
                events?.success(mapOf("value" to Random().nextInt(100)))
            }
        }
        override fun onCancel(arguments: Any?) {
            timer?.cancel()
        }
    })
```

### Types de données supportés

| Flutter (Dart) | Android (Kotlin) | iOS (Swift) |
|----------------|------------------|-------------|
| `null` | `null` | `nil` |
| `bool` | `Boolean` | `Bool` |
| `int` | `Int`, `Long` | `Int`, `Int64` |
| `double` | `Double` | `Double` |
| `String` | `String` | `String` |
| `List` | `List` | `Array` |
| `Map` | `Map` | `Dictionary` |

---

## 📦 Installation

### Prérequis

- Flutter SDK ≥ 3.9.2
- Dart SDK ≥ 3.9.2
- Android Studio / Xcode

### Étapes

```bash
# 1. Cloner le projet
git clone <url-du-projet>
cd bloc_archi

# 2. Installer les dépendances
flutter pub get

# 3. Vérifier l'installation
flutter doctor

# 4. Lancer l'application
flutter run
```

### Dépendances principales

```yaml
dependencies:
  flutter_bloc: ^8.1.3    # Gestion d'état BLoC
  equatable: ^2.0.5       # Comparaison d'objets
  get_it: ^7.6.4          # Injection de dépendances
```

---

## 🚀 Utilisation

### Navigation dans l'application

L'application contient **2 démonstrations** :

1. **BLoC Pattern** : Compteur avec gestion d'état
   - Incrémentation/Décrémentation
   - Validation des limites
   - Gestion des erreurs
   - Métadonnées d'état

2. **Method Channels** : Communication native
   - Informations système (Android/iOS)
   - Niveau de batterie
   - Traitement de données
   - Flux d'événements

### Tests

```bash
# Tests unitaires (BLoC)
flutter test

# Tests d'intégration
flutter test integration_test

# Coverage
flutter test --coverage
```

---

## 📂 Structure des Fichiers

```
bloc_archi/
├── lib/
│   ├── core/                      # Code réutilisable
│   │   ├── blocs/
│   │   │   └── base_bloc.dart     # BLoC abstrait avec logging
│   │   └── channels/
│   │       └── platform_channel.dart  # Service Method Channels
│   │
│   ├── features/                  # Features par domaine
│   │   ├── counter/               # Démonstration BLoC
│   │   │   ├── bloc/
│   │   │   │   ├── counter_bloc.dart
│   │   │   │   ├── counter_event.dart
│   │   │   │   └── counter_state.dart
│   │   │   └── view/
│   │   │       └── counter_page.dart
│   │   │
│   │   └── native_communication/  # Démonstration Method Channels
│   │       ├── bloc/
│   │       └── view/
│   │
│   └── main.dart                  # Point d'entrée
│
├── android/
│   └── app/src/main/kotlin/.../MainActivity.kt  # Code Android
│
├── ios/
│   └── Runner/AppDelegate.swift   # Code iOS
│
├── docs/
│   └── ANNEXES.md                 # Documentation pour rapport
│
└── README.md                      # Ce fichier
```

---

## 📚 Ressources

### Documentation officielle

- [Flutter BLoC Library](https://bloclibrary.dev/)
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)

### Articles et tutoriels

- [BLoC Pattern: A Complete Guide](https://verygood.ventures/blog/flutter-bloc-pattern)
- [Understanding Method Channels](https://medium.com/flutter-community/flutter-platform-channels-ce7f540a104e)
- [State Management in Flutter](https://docs.flutter.dev/data-and-backend/state-mgmt/options)

### Livres

- "Flutter Complete Reference" - Alberto Miola
- "Practical Flutter" - Frank Zammetti
- "Flutter in Action" - Eric Windmill

### Vidéos

- [Flutter BLoC - Official Tutorial](https://www.youtube.com/watch?v=THCkkQ-V1-8)
- [Method Channels Explained](https://www.youtube.com/watch?v=jBBl1tYkUnE)

---

## 🤝 Contribution

Ce projet est à des fins éducatives dans le cadre d'un rapport de stage.

---

## 📄 Licence

MIT License - Projet académique

---

## 👤 Auteur

**Projet de stage** - Migration d'une application native vers Flutter

**Contact** : [Votre email]

---

## 🎯 Objectifs pédagogiques

Ce projet démontre :

✅ Maîtrise de l'architecture BLoC
✅ Compréhension des Method Channels
✅ Séparation des responsabilités
✅ Communication Flutter-Native
✅ Bonnes pratiques Flutter
✅ Code documenté et maintenable

---

**Date de création** : 2025
**Dernière mise à jour** : 2025
