# Guide d'Installation et d'Exécution

## Prérequis

### Logiciels nécessaires

- **Flutter SDK** : Version ≥ 3.9.2
- **Dart SDK** : Version ≥ 3.9.2
- **Android Studio** : Pour développement Android
- **Xcode** : Pour développement iOS (macOS uniquement)
- **Git** : Pour cloner le projet

### Vérification de l'installation Flutter

```bash
flutter doctor
```

Cette commande vérifie que tout est correctement installé.

---

## Installation

### Étape 1 : Cloner le projet

```bash
git clone <url-du-projet>
cd bloc_archi
```

### Étape 2 : Installer les dépendances

```bash
flutter pub get
```

Cette commande télécharge toutes les dépendances définies dans `pubspec.yaml` :
- `flutter_bloc` : Gestion d'état
- `equatable` : Comparaison d'objets
- `get_it` : Injection de dépendances

### Étape 3 : Vérifier la configuration

```bash
flutter doctor -v
```

Assurez-vous que :
- ✓ Flutter est installé
- ✓ Au moins un appareil/émulateur est disponible
- ✓ Android toolchain est configuré (pour Android)
- ✓ Xcode est configuré (pour iOS sur macOS)

---

## Exécution

### Sur un émulateur Android

```bash
# Lister les émulateurs disponibles
flutter emulators

# Démarrer un émulateur
flutter emulators --launch <emulator_id>

# Lancer l'application
flutter run
```

### Sur un appareil Android physique

1. Activez le **mode développeur** sur votre appareil
2. Activez le **débogage USB**
3. Connectez l'appareil via USB
4. Exécutez :

```bash
flutter devices  # Vérifier que l'appareil est détecté
flutter run
```

### Sur un émulateur iOS (macOS uniquement)

```bash
# Ouvrir le simulateur iOS
open -a Simulator

# Lancer l'application
flutter run
```

### Sur un appareil iOS physique (macOS uniquement)

1. Connectez l'appareil via USB
2. Configurez le certificat de développement dans Xcode
3. Exécutez :

```bash
flutter run
```

---

## Mode de développement

### Hot Reload

Pendant l'exécution, pressez `r` dans le terminal pour recharger l'application instantanément sans perdre l'état.

```bash
# L'application est en cours d'exécution
r  # Hot reload
R  # Hot restart (réinitialise l'état)
```

### Hot Restart

Pressez `R` pour redémarrer complètement l'application.

---

## Build

### Build Android (APK)

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Le fichier se trouve dans : build/app/outputs/flutter-apk/
```

### Build Android (App Bundle)

```bash
flutter build appbundle --release

# Le fichier se trouve dans : build/app/outputs/bundle/release/
```

### Build iOS (macOS uniquement)

```bash
flutter build ios --release

# Ouvrir Xcode pour archiver
open ios/Runner.xcworkspace
```

---

## Tests

### Tests unitaires

```bash
flutter test
```

### Tests avec coverage

```bash
flutter test --coverage
```

### Analyse du code

```bash
flutter analyze
```

---

## Résolution des problèmes

### Problème : Dépendances non résolues

```bash
flutter clean
flutter pub get
```

### Problème : Émulateur ne démarre pas

```bash
# Android
flutter emulators --launch <emulator_id>

# iOS
open -a Simulator
```

### Problème : Appareil non détecté

```bash
# Vérifier les appareils connectés
flutter devices

# Android : Vérifier adb
adb devices

# Redémarrer adb
adb kill-server
adb start-server
```

### Problème : Build échoue

```bash
# Nettoyer le projet
flutter clean

# Mettre à jour Flutter
flutter upgrade

# Réinstaller les dépendances
flutter pub get

# Rebuild
flutter run
```

---

## Structure du projet après installation

```
bloc_archi/
├── android/              # Code natif Android
├── ios/                  # Code natif iOS
├── lib/                  # Code Flutter (Dart)
│   ├── core/            # Code réutilisable
│   ├── features/        # Fonctionnalités
│   └── main.dart        # Point d'entrée
├── test/                # Tests unitaires
├── docs/                # Documentation
├── pubspec.yaml         # Dépendances
└── README.md            # Documentation principale
```

---

## Commandes utiles

| Commande | Description |
|----------|-------------|
| `flutter doctor` | Vérifie l'installation |
| `flutter pub get` | Installe les dépendances |
| `flutter run` | Lance l'application |
| `flutter test` | Exécute les tests |
| `flutter clean` | Nettoie le projet |
| `flutter analyze` | Analyse le code |
| `flutter build apk` | Build APK Android |
| `flutter devices` | Liste les appareils |

---

## Support

En cas de problème :
1. Consultez la [documentation Flutter](https://docs.flutter.dev/)
2. Vérifiez les [issues GitHub](https://github.com/flutter/flutter/issues)
3. Consultez le README.md du projet

---

**Bonne utilisation !**
