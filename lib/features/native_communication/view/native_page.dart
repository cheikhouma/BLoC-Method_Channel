/// Page de démonstration des Method Channels
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/native_bloc.dart';
import '../bloc/native_event.dart';
import '../bloc/native_state.dart';

class NativePage extends StatelessWidget {
  const NativePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NativeBloc(),
      child: const NativeView(),
    );
  }
}

class NativeView extends StatelessWidget {
  const NativeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Method Channels Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocListener<NativeBloc, NativeState>(
        listener: (context, state) {
          if (state is NativeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section: Informations système
              _buildSection(
                context,
                title: 'Informations Système',
                icon: Icons.info,
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<NativeBloc>().add(const LoadSystemInfo());
                      },
                      icon: const Icon(Icons.phone_android),
                      label: const Text('Charger les informations'),
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<NativeBloc, NativeState>(
                      builder: (context, state) {
                        if (state is SystemInfoLoaded) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('Plateforme', state.platform),
                                  _buildInfoRow('Version', state.version),
                                  ...state.additionalInfo.entries.map(
                                    (e) => _buildInfoRow(
                                      e.key,
                                      e.value.toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section: Niveau de batterie
              _buildSection(
                context,
                title: 'Niveau de Batterie',
                icon: Icons.battery_charging_full,
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<NativeBloc>().add(
                          const LoadBatteryLevel(),
                        );
                      },
                      icon: const Icon(Icons.battery_std),
                      label: const Text('Vérifier la batterie'),
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<NativeBloc, NativeState>(
                      builder: (context, state) {
                        if (state is BatteryLevelLoaded) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    '${state.batteryIcon} ${state.level}%',
                                    style: const TextStyle(fontSize: 48),
                                  ),
                                  Text(
                                    'Mis à jour: ${_formatTime(state.timestamp)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section: Traitement de données
              _buildSection(
                context,
                title: 'Traitement de Données Natives',
                icon: Icons.data_object,
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showProcessDataDialog(context),
                      icon: const Icon(Icons.send),
                      label: const Text('Envoyer des données'),
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<NativeBloc, NativeState>(
                      builder: (context, state) {
                        if (state is NativeDataProcessed) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: state.processedData.entries
                                    .map(
                                      (e) => _buildInfoRow(
                                        e.key,
                                        e.value.toString(),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Indicateur de chargement
              BlocBuilder<NativeBloc, NativeState>(
                builder: (context, state) {
                  if (state is NativeLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _showProcessDataDialog(BuildContext context) {
    final messageController = TextEditingController();
    final countController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Traiter des données'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final message = messageController.text;
              final count = int.tryParse(countController.text) ?? 0;

              context.read<NativeBloc>().add(
                ProcessNativeData(message: message, count: count),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
