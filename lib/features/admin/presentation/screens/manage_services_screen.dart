import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/business_providers.dart';

class ManageServicesScreen extends ConsumerWidget {
  final String businessId;

  const ManageServicesScreen({super.key, required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(adminServicesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Gestionar Servicios',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return const Center(
              child: Text(
                'No hay servicios vigentes.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF), // Light Blue surface
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cut_outlined, color: Color(0xFF3B82F6)),
                  ),
                   title: Text(
                    service.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '\$${service.price}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(service.duration, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: IconButton(
                    icon:
                        const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      _confirmDelete(context, ref, service.id, service.name);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String? serviceId, String? name) async {
    if (serviceId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: Text('¿Estás seguro de que deseas eliminar "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(serviceRepositoryProvider)
            .deleteService(businessId, serviceId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio eliminado con éxito')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar servicio: $e')),
        );
      }
    }
  }
}
