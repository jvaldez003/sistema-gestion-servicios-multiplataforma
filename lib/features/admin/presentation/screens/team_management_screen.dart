import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sistema_gestion_servicios_multiplataforma/core/theme/app_colors.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/admin/presentation/widgets/add_member_flow.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/business_details_providers.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/business_providers.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/booking_providers.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/auth/domain/entities/app_user.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/auth/presentation/providers/auth_providers.dart';

class TeamManagementScreen extends ConsumerStatefulWidget {
  final String businessId;
  const TeamManagementScreen({super.key, required this.businessId});

  @override
  ConsumerState<TeamManagementScreen> createState() =>
      _TeamManagementScreenState();
}

class _TeamManagementScreenState extends ConsumerState<TeamManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamAsync = ref.watch(businessTeamProvider(widget.businessId));
    final workRequestsAsync = ref.watch(businessWorkRequestsProvider(widget.businessId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: teamAsync.when(
        data: (members) {
          final activeCount = members.where((m) => m['status'] == 'active').length;
          final workRequestsCount = workRequestsAsync.maybeWhen(
            data: (requests) => requests.length,
            orElse: () => 0,
          );

          return CustomScrollView(
            slivers: [
              // Orange Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF97316),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('Gestión del Equipo',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Stats Row
                      Row(
                        children: [
                          _buildHeaderStat('${members.length}', 'Total', Colors.white),
                          const SizedBox(width: 12),
                          _buildHeaderStat('$activeCount', 'Activos hoy', Colors.white),
                          const SizedBox(width: 12),
                          _buildHeaderStat('$workRequestsCount', 'Solicitudes', Colors.white,
                              badge: workRequestsCount > 0),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      onTap: (_) => setState(() {}),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha:0.05),
                              blurRadius: 4)
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.black,
                      unselectedLabelColor: AppColors.textSecondary,
                      dividerHeight: 0,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people_outline, size: 16),
                              const SizedBox(width: 6),
                              Text('Equipo (${members.length})',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.mail_outline, size: 16),
                              const SizedBox(width: 6),
                              Text('Solicitudes',
                                  style: const TextStyle(fontSize: 12)),
                              if (workRequestsCount > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text('$workRequestsCount',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Invite Card
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.group_add, color: Colors.black54),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Invita a tu equipo',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('Comparte el link o agrega manualmente',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              Share.share(
                                'Te invito a unirte a mi equipo en FlowServ. Descarga la app y solicita unirte al negocio: https://flowserv.app',
                                subject: 'Únete a mi equipo en FlowServ',
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            child: const Text('Invitar',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton(
                            onPressed: () => _showAddMember(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            child: const Text('+ Agregar',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      TextButton.icon(
                        onPressed: () => _showUserSearch(context),
                        icon: const Icon(Icons.person_search, size: 16),
                        label: const Text('Buscar usuario registrado en la app'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Members List
              if (_tabController.index == 0)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  sliver: members.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(Icons.people_outline,
                                      size: 48, color: AppColors.textSecondary),
                                  const SizedBox(height: 12),
                                  const Text('No hay miembros aún',
                                      style: TextStyle(
                                          color: AppColors.textSecondary)),
                                  const SizedBox(height: 8),
                                  const Text(
                                      'Agrega tu primer trabajador al equipo',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final member = members[index];
                              return _buildMemberCard(member);
                            },
                            childCount: members.length,
                          ),
                        ),
                ),

              // Solicitudes Tab
              if (_tabController.index == 1)
                workRequestsAsync.when(
                  data: (requests) {
                    if (requests.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(48),
                            child: Column(
                              children: [
                                Icon(Icons.mail_outline,
                                    size: 48, color: AppColors.textSecondary),
                                const SizedBox(height: 12),
                                Text('No hay solicitudes pendientes',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final request = requests[index];
                            return _buildWorkRequestCard(request, ref);
                          },
                          childCount: requests.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator())),
                  ),
                  error: (err, __) => SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(48), child: Text('Error: $err'))),
                  ),
                )
              else
                const SliverToBoxAdapter(),

              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMember(),
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showUserSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserSearchSheet(businessId: widget.businessId),
    );
  }

  void _showMemberSchedule(BuildContext context, Map<String, dynamic> member) {
    final professionalId = member['id'] as String? ?? '';
    final name = member['name'] ?? 'Miembro';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Consumer(
        builder: (ctx, ref, _) {
          final apptAsync = ref.watch(memberScheduleProvider(professionalId));
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            expand: false,
            builder: (_, scrollCtrl) => Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Agenda de $name', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: apptAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (appointments) {
                      final upcoming = appointments
                          .where((a) => a.status != 'cancelled' && a.dateTime.isAfter(DateTime.now().subtract(const Duration(hours: 1))))
                          .toList()
                        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
                      if (upcoming.isEmpty) {
                        return const Center(child: Text('Sin citas próximas', style: TextStyle(color: AppColors.textSecondary)));
                      }
                      return ListView.separated(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: upcoming.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final a = upcoming[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha:0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                DateFormat('HH:mm').format(a.dateTime),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                              ),
                            ),
                            title: Text(a.serviceNames.join(', '), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(DateFormat('d MMM yyyy', 'es').format(a.dateTime)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: a.status == 'confirmed' ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                a.status == 'confirmed' ? 'Confirmada' : 'Pendiente',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: a.status == 'confirmed' ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddMember() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMemberFlow(businessId: widget.businessId),
    );
  }

  void _editMember(Map<String, dynamic> member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMemberFlow(
        businessId: widget.businessId,
        existingMember: member,
      ),
    );
  }

  Future<void> _confirmDeleteMember(Map<String, dynamic> member) async {
    final name = member['name'] ?? 'este miembro';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text('¿Estás seguro de que deseas eliminar a "$name" del equipo?'),
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
        await ref.read(teamRepositoryProvider).removeTeamMember(widget.businessId, member['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Miembro eliminado con éxito')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  Widget _buildHeaderStat(String value, String label, Color textColor,
      {bool badge = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Column(
                children: [
                  Text(value,
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  Text(label,
                      style: TextStyle(
                          color: textColor.withValues(alpha:0.8), fontSize: 11)),
                ],
              ),
            ),
            if (badge)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final name = member['name'] ?? 'Sin nombre';
    final role = member['role'] ?? 'Sin rol';
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : '??';
    final commission = (member['commission'] ?? 0).toDouble();
    final isActive = member['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 22,
                child: Text(initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(role,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(isActive ? 'Activo' : 'Pendiente',
                    style: TextStyle(
                        color: isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _buildMemberStat('${commission.toInt()}%', 'Comisión'),
            ],
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showMemberSchedule(context, member),
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label:
                      const Text('Ver agenda', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editMember(member);
                  } else if (value == 'delete') {
                    _confirmDeleteMember(member);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkRequestCard(
      Map<String, dynamic> request, WidgetRef ref) {
    final requesterName = request['requesterName'] ?? 'Usuario desconocido';
    final requesterAvatar = request['requesterAvatar'] ?? '';
    final requestId = request['id'] ?? '';

    final initials = requesterName.isNotEmpty
        ? requesterName
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : '??';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          // Header with avatar and name
          Row(
            children: [
              if (requesterAvatar.isNotEmpty)
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(requesterAvatar),
                )
              else
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(requesterName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const Text('Solicitud de trabajo',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(teamRepositoryProvider)
                          .rejectWorkRequest(widget.businessId, requestId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Solicitud rechazada')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Color(0xFFFFCDD2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Rechazar',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(teamRepositoryProvider)
                          .acceptWorkRequest(widget.businessId, requestId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Solicitud aceptada! El usuario se ha agregado al equipo.')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Aceptar',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserSearchSheet extends ConsumerStatefulWidget {
  final String businessId;
  const _UserSearchSheet({required this.businessId});

  @override
  ConsumerState<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends ConsumerState<_UserSearchSheet> {
  final _controller = TextEditingController();
  List<AppUser> _results = [];
  bool _isLoading = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();
    if (trimmed == _lastQuery) return;
    _lastQuery = trimmed;
    if (trimmed.isEmpty) {
      setState(() { _results = []; _isLoading = false; });
      return;
    }
    setState(() => _isLoading = true);
    try {
      final results = await ref.read(userRepositoryProvider).searchUsers(trimmed);
      if (mounted && trimmed == _lastQuery) {
        setState(() { _results = results; _isLoading = false; });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addMember(AppUser user) async {
    try {
      await ref.read(teamRepositoryProvider).setTeamMember(
        widget.businessId,
        user.id,
        {
          'userId': user.id,
          'name': user.name ?? user.email,
          'email': user.email,
          'photoUrl': user.photoUrl ?? '',
          'role': 'Professional',
          'commission': 50,
          'status': 'active',
          'joinedAt': DateTime.now().toIso8601String(),
        },
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name ?? user.email} agregado al equipo'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Buscar usuario', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Nombre o correo electrónico',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFF97316)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else if (_results.isEmpty && _lastQuery.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No se encontraron usuarios', style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (_, i) {
                  final user = _results[i];
                  final name = user.name ?? user.email;
                  final initials = name.isNotEmpty
                      ? name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join()
                      : '?';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                          ? Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))
                          : null,
                    ),
                    title: Text(user.name ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(user.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    trailing: ElevatedButton(
                      onPressed: () => _addMember(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        elevation: 0,
                      ),
                      child: const Text('Agregar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
