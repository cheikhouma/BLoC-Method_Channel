/// Page du compteur avec architecture BLoC
///
/// Démontre l'utilisation de BlocProvider, BlocBuilder et BlocListener
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/counter_bloc.dart';
import '../bloc/counter_event.dart';
import '../bloc/counter_state.dart';

/// Page principale du compteur
///
/// Utilise BlocProvider pour fournir le CounterBloc aux widgets enfants
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Création et fourniture du BLoC
      create: (context) => CounterBloc(),
      child: const CounterView(),
    );
  }
}

/// Vue du compteur
///
/// Sépare la création du BLoC (dans CounterPage)
/// de son utilisation (dans CounterView)
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter - BLoC Pattern'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Bouton de réinitialisation
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Envoi d'un événement au BLoC
              context.read<CounterBloc>().add(const CounterReset());
            },
            tooltip: 'Réinitialiser',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // BlocListener : Réagit aux changements d'état
            // (affichage de messages, navigation, etc.)
            BlocListener<CounterBloc, CounterState>(
              listener: (context, state) {
                // Affichage d'un message en cas d'erreur
                if (state is CounterError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const SizedBox.shrink(),
            ),

            // Texte descriptif
            const Text(
              'Vous avez appuyé sur le bouton :',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // BlocBuilder : Reconstruit l'UI en fonction de l'état
            BlocBuilder<CounterBloc, CounterState>(
              builder: (context, state) {
                // Affichage conditionnel selon le type d'état
                if (state is CounterLoading) {
                  return const CircularProgressIndicator();
                }

                if (state is CounterValue) {
                  return Column(
                    children: [
                      // Affichage de la valeur du compteur
                      Text(
                        '${state.value}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: state.isAtMax
                                  ? Colors.red
                                  : state.isAtMin
                                      ? Colors.blue
                                      : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),

                      // Indicateurs visuels
                      if (state.isAtMax)
                        const Chip(
                          label: Text('Maximum atteint'),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      if (state.isAtMin)
                        const Chip(
                          label: Text('Minimum atteint'),
                          backgroundColor: Colors.blue,
                          labelStyle: TextStyle(color: Colors.white),
                        ),

                      const SizedBox(height: 20),

                      // Informations additionnelles
                      Text(
                        'Dernière modification: ${_formatTime(state.lastUpdated)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                }

                // État par défaut
                return const Text('État inconnu');
              },
            ),

            const SizedBox(height: 40),

            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton de décrémentation
                FloatingActionButton(
                  heroTag: 'decrement',
                  onPressed: () {
                    // Envoi de l'événement de décrémentation
                    context.read<CounterBloc>().add(const CounterDecremented());
                  },
                  tooltip: 'Décrémenter',
                  child: const Icon(Icons.remove),
                ),

                const SizedBox(width: 20),

                // Bouton d'incrémentation
                FloatingActionButton(
                  heroTag: 'increment',
                  onPressed: () {
                    // Envoi de l'événement d'incrémentation
                    context.read<CounterBloc>().add(const CounterIncremented());
                  },
                  tooltip: 'Incrémenter',
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Exemple de définition directe de valeur
            ElevatedButton.icon(
              onPressed: () => _showSetValueDialog(context),
              icon: const Icon(Icons.edit),
              label: const Text('Définir une valeur'),
            ),
          ],
        ),
      ),
    );
  }

  /// Formatte l'heure au format HH:MM:SS
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Affiche un dialogue pour définir une valeur
  void _showSetValueDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Définir une valeur'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Valeur (0-100)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null) {
                // Envoi de l'événement avec la valeur
                context.read<CounterBloc>().add(CounterValueSet(value));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
