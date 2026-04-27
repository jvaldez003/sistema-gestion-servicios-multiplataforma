import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class PersonalDataScreen extends ConsumerStatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  ConsumerState<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends ConsumerState<PersonalDataScreen> {
  bool _isSaving = false;

  Future<void> _editField({
    required String title,
    required String currentValue,
    required Future<void> Function(String newValue) onSave,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Editar $title',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: true,
          decoration: InputDecoration(
            labelText: title,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentValue) {
      setState(() => _isSaving = true);
      try {
        await onSave(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title actualizado correctamente'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _editPhotoUrl(String userId, String currentUrl) async {
    final controller = TextEditingController(text: currentUrl);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Actualizar foto de perfil',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pega la URL de tu nueva foto de perfil',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'URL de la imagen',
                hintText: 'https://...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null && result != currentUrl) {
      setState(() => _isSaving = true);
      try {
        await ref.read(userRepositoryProvider).updateUserProfile(userId, photoUrl: result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto actualizada correctamente'),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Datos personales',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: userProfileAsync.when(
        data: (userData) {
          if (userData == null) {
            return const Center(child: Text('No se encontraron datos personales'));
          }

          return CustomScrollView(
            slivers: [
              // ── Avatar Section ─────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _editPhotoUrl(userData.id, userData.photoUrl ?? ''),
                        child: Stack(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppColors.primary, AppColors.primaryLight],
                                ),
                                borderRadius: BorderRadius.circular(55),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(55),
                                child: userData.photoUrl != null && userData.photoUrl!.isNotEmpty
                                    ? AppCachedImage(
                                        imageUrl: userData.photoUrl!,
                                        borderRadius: BorderRadius.circular(55),
                                      )
                                    : Center(
                                        child: Text(
                                          (userData.name != null && userData.name!.isNotEmpty)
                                              ? userData.name![0].toUpperCase()
                                              : '?',
                                          style: AppTypography.h1.copyWith(
                                            color: Colors.white,
                                            fontSize: 40,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Toca la foto para cambiarla',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

              // ── Info Section Header ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    'Información Personal',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

              // ── Editable Fields ─────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildEditableField(
                        icon: Icons.person_outline,
                        label: 'Nombre Completo',
                        value: userData.name?.isNotEmpty == true
                            ? userData.name!
                            : 'No configurado',
                        onEdit: () => _editField(
                          title: 'Nombre',
                          currentValue: userData.name ?? '',
                          onSave: (val) => ref
                              .read(userRepositoryProvider)
                              .updateUserProfile(userData.id, name: val),
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F5F9)),
                      _buildEditableField(
                        icon: Icons.email_outlined,
                        label: 'Correo Electrónico',
                        value: userData.email.isNotEmpty
                            ? userData.email
                            : 'No configurado',
                        onEdit: () => _editField(
                          title: 'Correo',
                          currentValue: userData.email,
                          keyboardType: TextInputType.emailAddress,
                          onSave: (val) => ref
                              .read(userRepositoryProvider)
                              .updateUserProfile(userData.id, email: val),
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF1F5F9)),
                      _buildEditableField(
                        icon: Icons.phone_outlined,
                        label: 'Teléfono',
                        value: userData.phoneNumber?.isNotEmpty == true
                            ? userData.phoneNumber!
                            : 'No configurado',
                        onEdit: () => _editField(
                          title: 'Teléfono',
                          currentValue: userData.phoneNumber ?? '',
                          keyboardType: TextInputType.phone,
                          onSave: (val) => ref
                              .read(userRepositoryProvider)
                              .updateUserProfile(userData.id, phoneNumber: val),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

              // ── Account Stats ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    'Resumen de Cuenta',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.stars_rounded,
                          color: const Color(0xFFF59E0B),
                          label: 'Puntos',
                          value: '${userData.points}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.favorite_outline_rounded,
                          color: const Color(0xFFEC4899),
                          label: 'Favoritos',
                          value: '${userData.favoriteIds.length}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.verified_user_outlined,
                          color: AppColors.primary,
                          label: 'Estado',
                          value: 'Activo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

              // ── Info banner ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Tus datos personales están protegidos y encriptados.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(isLast ? 0 : 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_outlined, size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
