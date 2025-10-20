# ANNEXES - Rapport de Stage

## Migration d'une Application Native vers Flutter

> Document complémentaire au rapport de stage - Extraits de code et documentation technique

---

## Table des matières

1. [Annexe A : Architecture BLoC - Extraits de Code](#annexe-a--architecture-bloc---extraits-de-code)
2. [Annexe B : Method Channels - Implémentation](#annexe-b--method-channels---implémentation)
3. [Annexe C : Diagrammes d'Architecture](#annexe-c--diagrammes-darchitecture)
4. [Annexe D : Liste de Ressources](#annexe-d--liste-de-ressources)

---

## Annexe A : Architecture BLoC - Extraits de Code

### A.1 - BLoC Abstrait de Base

**Fichier :** `lib/core/blocs/base_bloc.dart`

```dart
/// Classe abstraite de base pour tous les BLoCs
///
/// Cette classe définit la structure commune que tous les BLoCs
/// doivent suivre dans l'application.
import 'package:flutter_bloc/flutter_bloc.dart';

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

  /// Log des changements d'état
  void logStateChange(Change<S> change) {
    print('🟢 [${runtimeType}] State: ${change.currentState} → ${change.nextState}');
  }

  /// Log des erreurs
  void logError(Object error, StackTrace stackTrace) {
    print('🔴 [${runtimeType}] Error: $error');
  }
}
```

**Explication ligne par ligne :**

| Ligne | Code | Explication |
|-------|------|-------------|
| 8 | `abstract class BaseBloc<E, S>` | Classe générique avec types Event et State |
| 9 | `extends Bloc<E, S>` | Hérite du BLoC de flutter_bloc |
| 10 | `super(initialState)` | Initialise avec un état de départ |
| 15-18 | `onEvent()` | Intercepte chaque événement reçu |
| 21-24 | `onChange()` | Intercepte chaque changement d'état |
| 27-30 | `onError()` | Intercepte les erreurs |
| 33-35 | `logEvent()` | Log personnalisé pour le débogage |

**Avantages :**
- Centralisation du logging
- Monitoring des événements et états
- Facilite le débogage
- Réutilisable pour tous les BLoCs

---

### A.2 - Événements du Compteur

**Fichier :** `lib/features/counter/bloc/counter_event.dart`

```dart
import 'package:equatable/equatable.dart';

/// Classe abstraite de base pour tous les événements
abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object?> get props => [];
}

/// Événement : Incrémenter le compteur
class CounterIncremented extends CounterEvent {
  const CounterIncremented();

  @override
  String toString() => 'CounterIncremented';
}

/// Événement : Décrémenter le compteur
class CounterDecremented extends CounterEvent {
  const CounterDecremented();

  @override
  String toString() => 'CounterDecremented';
}

/// Événement : Réinitialiser le compteur
class CounterReset extends CounterEvent {
  const CounterReset();

  @override
  String toString() => 'CounterReset';
}

/// Événement : Définir une valeur spécifique
class CounterValueSet extends CounterEvent {
  final int value;

  const CounterValueSet(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'CounterValueSet { value: $value }';
}
```

**Points clés :**

1. **Héritage d'Equatable** : Permet la comparaison automatique
2. **Immutabilité** : Tous les événements sont `const`
3. **Props** : Liste des propriétés pour la comparaison
4. **toString()** : Facilite le débogage

---

### A.3 - États du Compteur

**Fichier :** `lib/features/counter/bloc/counter_state.dart`

```dart
import 'package:equatable/equatable.dart';

/// Classe abstraite de base pour tous les états
abstract class CounterState extends Equatable {
  const CounterState();

  @override
  List<Object?> get props => [];
}

/// État : Valeur du compteur
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

  /// État initial
  factory CounterValue.initial() {
    return CounterValue(
      value: 0,
      isAtMin: true,
      lastUpdated: DateTime.now(),
    );
  }

  /// Pattern copyWith pour l'immutabilité
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
}

/// État : Erreur
class CounterError extends CounterState {
  final String message;

  const CounterError(this.message);

  @override
  List<Object?> get props => [message];
}
```

**Concepts importants :**

| Concept | Ligne | Description |
|---------|-------|-------------|
| **Factory Constructor** | 26-31 | Crée un état initial standardisé |
| **Pattern copyWith** | 34-46 | Crée une copie avec modifications |
| **Immutabilité** | 12-16 | Tous les champs sont `final` |
| **Props Equatable** | 49 | Définit les champs pour comparaison |

---

### A.4 - BLoC du Compteur (Logique Métier)

**Fichier :** `lib/features/counter/bloc/counter_bloc.dart`

```dart
import 'package:bloc_archi/core/blocs/base_bloc.dart';
import 'counter_event.dart';
import 'counter_state.dart';

class CounterBloc extends BaseBloc<CounterEvent, CounterState> {
  static const int maxValue = 100;
  static const int minValue = 0;

  CounterBloc() : super(CounterValue.initial()) {
    // Enregistrement des gestionnaires d'événements
    on<CounterIncremented>(_onIncremented);
    on<CounterDecremented>(_onDecremented);
    on<CounterReset>(_onReset);
    on<CounterValueSet>(_onValueSet);
  }

  /// Gestionnaire : Incrémentation
  Future<void> _onIncremented(
    CounterIncremented event,
    Emitter<CounterState> emit,
  ) async {
    final currentState = state;

    if (currentState is CounterValue) {
      final newValue = currentState.value + 1;

      // Validation de la limite maximale
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
        lastUpdated: DateTime.now(),
      ));
    }
  }

  /// Gestionnaire : Décrémentation
  Future<void> _onDecremented(
    CounterDecremented event,
    Emitter<CounterState> emit,
  ) async {
    final currentState = state;

    if (currentState is CounterValue) {
      final newValue = currentState.value - 1;

      if (newValue < minValue) {
        emit(const CounterError('Valeur minimale atteinte'));
        await Future.delayed(const Duration(seconds: 2));
        emit(currentState);
        return;
      }

      emit(currentState.copyWith(
        value: newValue,
        isAtMin: newValue <= minValue,
        isAtMax: false,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  /// Gestionnaire : Réinitialisation
  void _onReset(CounterReset event, Emitter<CounterState> emit) {
    emit(CounterValue.initial());
  }
}
```

**Flux d'exécution :**

```
┌──────────────────┐
│ User Action      │ → Appui sur bouton +
└────────┬─────────┘
         ↓
┌──────────────────┐
│ Event Dispatch   │ → add(CounterIncremented())
└────────┬─────────┘
         ↓
┌──────────────────┐
│ BLoC Handler     │ → _onIncremented()
└────────┬─────────┘
         ↓
┌──────────────────┐
│ Business Logic   │ → Validation + Calcul
└────────┬─────────┘
         ↓
┌──────────────────┐
│ State Emission   │ → emit(newState)
└────────┬─────────┘
         ↓
┌──────────────────┐
│ UI Rebuild       │ → BlocBuilder reconstruit l'UI
└──────────────────┘
```

---

### A.5 - Utilisation dans l'Interface Utilisateur

**Fichier :** `lib/features/counter/view/counter_page.dart` (extrait)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Fournir le BLoC à l'arbre de widgets
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 2. Écouter les états pour les effets secondaires
          BlocListener<CounterBloc, CounterState>(
            listener: (context, state) {
              if (state is CounterError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: const SizedBox.shrink(),
          ),

          // 3. Reconstruire l'UI selon l'état
          BlocBuilder<CounterBloc, CounterState>(
            builder: (context, state) {
              if (state is CounterValue) {
                return Text(
                  '${state.value}',
                  style: Theme.of(context).textTheme.displayLarge,
                );
              }
              return const Text('État inconnu');
            },
          ),

          // 4. Envoyer des événements au BLoC
          FloatingActionButton(
            onPressed: () {
              context.read<CounterBloc>().add(
                const CounterIncremented(),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
```

**Widgets BLoC clés :**

| Widget | Rôle | Utilisation |
|--------|------|-------------|
| `BlocProvider` | Fournit le BLoC | Créé une fois en haut de l'arbre |
| `BlocBuilder` | Reconstruit l'UI | Utilisé pour afficher les données |
| `BlocListener` | Effets secondaires | SnackBar, Navigation, etc. |
| `context.read<T>()` | Accède au BLoC | Pour envoyer des événements |
| `context.watch<T>()` | Écoute les changements | Reconstruit automatiquement |

---

## Annexe B : Method Channels - Implémentation

### B.1 - Service Flutter (Dart)

**Fichier :** `lib/core/channels/platform_channel.dart`

```dart
import 'package:flutter/services.dart';

class PlatformChannelService {
  /// Canal de communication (nom identique côté natif)
  static const MethodChannel _channel =
      MethodChannel('com.example.bloc_archi/native');

  /// Canal d'événements pour flux continus
  static const EventChannel _eventChannel =
      EventChannel('com.example.bloc_archi/native_events');

  /// Obtenir les informations système
  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('getSystemInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print("Erreur: ${e.message}");
      return {
        'platform': 'Unknown',
        'version': 'N/A',
        'error': e.message,
      };
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

  /// Traiter des données avec le code natif
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
      return {'error': e.message};
    }
  }

  /// Écouter des événements natifs en continu
  Stream<Map<String, dynamic>> listenToNativeEvents() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }
}
```

**Architecture de communication :**

```
Flutter (Dart)                           Native (Kotlin/Swift)
─────────────────                        ─────────────────────
MethodChannel                            MethodChannel
     │                                           │
     │  invokeMethod('getSystemInfo')           │
     ├──────────────────────────────────────────>│
     │                                           │
     │  Map<String, dynamic>                     │
     │<──────────────────────────────────────────┤
     │                                           │

EventChannel                             EventChannel
     │                                           │
     │  receiveBroadcastStream()                 │
     │<══════════════════════════════════════════│
     │  Stream<Map<String, dynamic>>             │
     │                                           │
```

---

### B.2 - Implémentation Android (Kotlin)

**Fichier :** `android/app/src/main/kotlin/.../MainActivity.kt`

```kotlin
package com.example.bloc_archi

import android.content.Context
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "com.example.bloc_archi/native"
    private val EVENT_CHANNEL = "com.example.bloc_archi/native_events"
    private var timer: Timer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupMethodChannel(flutterEngine)
        setupEventChannel(flutterEngine)
    }

    /// Configuration du Method Channel
    private fun setupMethodChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSystemInfo" -> {
                    try {
                        val systemInfo = getSystemInfo()
                        result.success(systemInfo)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }

                "getBatteryLevel" -> {
                    try {
                        val level = getBatteryLevel()
                        result.success(level)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }

                "processData" -> {
                    try {
                        val args = call.arguments as? Map<*, *>
                        val message = args?.get("message") as? String ?: ""
                        val count = args?.get("count") as? Int ?: 0

                        val processed = processData(message, count)
                        result.success(processed)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    /// Récupération des informations système
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

    /// Récupération du niveau de batterie
    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    /// Traitement de données
    private fun processData(message: String, count: Int): Map<String, Any> {
        return mapOf(
            "originalMessage" to message,
            "processedMessage" to message.uppercase(Locale.getDefault()),
            "originalCount" to count,
            "processedCount" to count * 2,
            "timestamp" to System.currentTimeMillis(),
            "processedBy" to "Android Native Code"
        )
    }

    /// Configuration de l'Event Channel
    private fun setupEventChannel(flutterEngine: FlutterEngine) {
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                timer = Timer()
                timer?.scheduleAtFixedRate(0, 1000) {
                    events?.success(mapOf(
                        "type" to "sensor_update",
                        "value" to Random().nextInt(100),
                        "timestamp" to System.currentTimeMillis()
                    ))
                }
            }

            override fun onCancel(arguments: Any?) {
                timer?.cancel()
                timer = null
            }
        })
    }

    override fun onDestroy() {
        timer?.cancel()
        super.onDestroy()
    }
}
```

**Points clés Android :**

| Méthode | Description |
|---------|-------------|
| `setMethodCallHandler` | Écoute les appels depuis Flutter |
| `result.success()` | Renvoie un résultat à Flutter |
| `result.error()` | Renvoie une erreur à Flutter |
| `result.notImplemented()` | Méthode non implémentée |
| `setStreamHandler` | Gère les flux d'événements |

---

### B.3 - Types de Données Supportés

| Flutter (Dart) | Android (Kotlin) | iOS (Swift) | Description |
|----------------|------------------|-------------|-------------|
| `null` | `null` | `nil` | Valeur nulle |
| `bool` | `Boolean` | `Bool` | Booléen |
| `int` | `Int`, `Long` | `Int`, `Int64` | Entier |
| `double` | `Double` | `Double` | Décimal |
| `String` | `String` | `String` | Chaîne de caractères |
| `List<T>` | `List<T>` | `Array` | Liste |
| `Map<K,V>` | `Map<K,V>` | `Dictionary` | Dictionnaire |
| `Uint8List` | `ByteArray` | `FlutterStandardTypedData` | Données binaires |

**Limitations :**
- Pas de types personnalisés directement
- Sérialisation nécessaire pour objets complexes
- Appels asynchrones uniquement

---

## Annexe C : Diagrammes d'Architecture

### C.1 - Architecture Globale du Projet

```
┌─────────────────────────────────────────────────────────────┐
│                      FLUTTER APPLICATION                     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────┐          ┌────────────────┐             │
│  │  Presentation  │          │  Presentation  │             │
│  │   (UI/Views)   │          │   (UI/Views)   │             │
│  └───────┬────────┘          └───────┬────────┘             │
│          │                           │                       │
│          ↓                           ↓                       │
│  ┌────────────────┐          ┌────────────────┐             │
│  │  CounterBloc   │          │   NativeBloc   │             │
│  │  (Business     │          │  (Business     │             │
│  │   Logic)       │          │   Logic)       │             │
│  └───────┬────────┘          └───────┬────────┘             │
│          │                           │                       │
│          │                           ↓                       │
│          │                  ┌────────────────┐               │
│          │                  │ PlatformChannel│               │
│          │                  │    Service     │               │
│          │                  └───────┬────────┘               │
│          │                           │                       │
└──────────┼───────────────────────────┼───────────────────────┘
           │                           │
           │                           ↓
           │                  ┌────────────────┐
           │                  │ Method Channels│
           │                  └───────┬────────┘
           │                           │
           │              ┌────────────┴────────────┐
           │              ↓                         ↓
   ┌───────┴────────┐  ┌──────────┐         ┌──────────┐
   │  Local State   │  │ Android  │         │   iOS    │
   │  Management    │  │ (Kotlin) │         │ (Swift)  │
   └────────────────┘  └──────────┘         └──────────┘
```

### C.2 - Flux de Données BLoC

```
   USER ACTION
        │
        ↓
   ┌────────┐
   │ Event  │ ─────> CounterIncremented()
   └────┬───┘
        │
        ↓
   ┌─────────────┐
   │    BLoC     │
   │             │
   │  Receives   │
   │   Event     │
   └─────┬───────┘
         │
         ↓
   ┌─────────────┐
   │  Business   │
   │   Logic     │
   │             │
   │ - Validate  │
   │ - Calculate │
   │ - Transform │
   └─────┬───────┘
         │
         ↓
   ┌─────────────┐
   │   State     │ ─────> CounterValue(value: 5)
   └─────┬───────┘
         │
         ↓
   ┌─────────────┐
   │ BlocBuilder │
   │  Rebuild    │
   │     UI      │
   └─────────────┘
         │
         ↓
    UI UPDATE
```

### C.3 - Flux Method Channels

```
Flutter Side                      Platform Side
─────────────                     ──────────────

User Action
    │
    ↓
invokeMethod()
    │
    ├──────────────────────────────>│
    │  "getBatteryLevel"             │
    │                                │
    │                                ↓
    │                          Process Request
    │                                │
    │                                ↓
    │                          Get Battery Info
    │                                │
    │                                ↓
    │         Result: 85             │
    │<───────────────────────────────┤
    │                                │
    ↓
Update UI
(85% Battery)
```

---

## Annexe D : Liste de Ressources

### D.1 - Documentation Officielle

#### Flutter
- **Site officiel** : https://flutter.dev/
- **Documentation** : https://docs.flutter.dev/
- **API Reference** : https://api.flutter.dev/

#### BLoC Pattern
- **BLoC Library** : https://bloclibrary.dev/
- **GitHub** : https://github.com/felangel/bloc
- **Examples** : https://github.com/felangel/bloc/tree/master/examples

#### Platform Channels
- **Documentation** : https://docs.flutter.dev/platform-integration/platform-channels
- **Cookbook** : https://docs.flutter.dev/cookbook

### D.2 - Articles et Tutoriels

#### BLoC Pattern
1. **"Flutter BLoC Pattern: The Complete Guide"**
   - Auteur : Very Good Ventures
   - URL : https://verygood.ventures/blog/flutter-bloc-pattern
   - Niveau : Intermédiaire

2. **"Understanding BLoC Pattern in Flutter"**
   - Auteur : Reso Coder
   - URL : https://resocoder.com/flutter-bloc-tutorial/
   - Niveau : Débutant

3. **"Advanced BLoC Architecture"**
   - Auteur : Felix Angelov
   - URL : https://bloclibrary.dev/#/architecture
   - Niveau : Avancé

#### Method Channels
1. **"Flutter Platform Channels Explained"**
   - Auteur : Flutter Community
   - URL : https://medium.com/flutter-community/flutter-platform-channels-ce7f540a104e
   - Niveau : Intermédiaire

2. **"Building Platform-Specific Features"**
   - Auteur : Flutter.dev
   - URL : https://docs.flutter.dev/platform-integration
   - Niveau : Intermédiaire

### D.3 - Livres Recommandés

1. **"Flutter Complete Reference"**
   - Auteur : Alberto Miola
   - Éditeur : Diligent Creative
   - ISBN : 978-1091772952
   - Chapitres pertinents : 8, 9, 12

2. **"Practical Flutter"**
   - Auteur : Frank Zammetti
   - Éditeur : Apress
   - ISBN : 978-1484249710
   - Chapitres pertinents : 5, 6

3. **"Flutter in Action"**
   - Auteur : Eric Windmill
   - Éditeur : Manning
   - ISBN : 978-1617296147
   - Chapitres pertinents : 7, 10

### D.4 - Vidéos et Cours

#### YouTube
1. **Flutter BLoC - Official Tutorial Series**
   - Chaîne : Reso Coder
   - URL : https://www.youtube.com/watch?v=THCkkQ-V1-8
   - Durée : ~4 heures (série complète)

2. **Method Channels Deep Dive**
   - Chaîne : Flutter
   - URL : https://www.youtube.com/watch?v=jBBl1tYkUnE
   - Durée : 25 minutes

#### Cours en ligne
1. **"Flutter & Dart - The Complete Guide"**
   - Plateforme : Udemy
   - Instructeur : Maximilian Schwarzmüller
   - Sections : BLoC, State Management, Platform Integration

2. **"Advanced Flutter Development"**
   - Plateforme : Pluralsight
   - Sections : Architecture Patterns, Native Integration

### D.5 - Outils et Packages

#### Packages Flutter Essentiels
```yaml
# Gestion d'état
flutter_bloc: ^8.1.3
bloc: ^8.1.2
equatable: ^2.0.5

# Injection de dépendances
get_it: ^7.6.4
injectable: ^2.3.2

# Communication réseau
dio: ^5.3.3
retrofit: ^4.0.3

# Tests
bloc_test: ^9.1.4
mocktail: ^1.0.1
```

#### Outils de Développement
- **Flutter DevTools** : Débogage et profiling
- **Bloc DevTools Extension** : Visualisation des événements/états
- **Android Studio / VS Code** : IDEs recommandés
- **Dart Code Metrics** : Analyse de code

### D.6 - Communautés et Support

#### Forums et Discussions
- **Stack Overflow** : Tag [flutter], [flutter-bloc]
- **Reddit** : r/FlutterDev
- **Discord** : Flutter Community Server
- **Slack** : Flutter Dev Slack

#### Blogs Techniques
- **Flutter Blog Officiel** : https://medium.com/flutter
- **Very Good Ventures Blog** : https://verygood.ventures/blog
- **Reso Coder** : https://resocoder.com

### D.7 - Dépôts GitHub de Référence

1. **Flutter Bloc Examples**
   - URL : https://github.com/felangel/bloc/tree/master/examples
   - Description : Exemples officiels du package BLoC

2. **Flutter Architecture Samples**
   - URL : https://github.com/brianegan/flutter_architecture_samples
   - Description : Comparaison de différentes architectures

3. **Reso Coder Clean Architecture**
   - URL : https://github.com/ResoCoder/flutter-tdd-clean-architecture-course
   - Description : Clean Architecture avec BLoC

---

## Conclusion des Annexes

Ces annexes fournissent :

✅ **Code complet et commenté** du pattern BLoC
✅ **Implémentation détaillée** des Method Channels
✅ **Diagrammes d'architecture** visuels
✅ **Ressources complètes** pour approfondir

Le code source complet est disponible dans le dépôt Git du projet.

---

**Références du Rapport Principal :**
- Chapitre 3 : Choix technologiques (BLoC Pattern)
- Chapitre 4 : Implémentation (Method Channels)
- Chapitre 5 : Architecture logicielle

---

**Document créé le :** 2025
**Projet :** Migration d'une application native vers Flutter
**Cadre :** Rapport de stage
