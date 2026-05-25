import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/models/appointment.dart';
import '../providers/admin_providers.dart';

class AdminFinancesScreen extends ConsumerStatefulWidget {
  final String businessId;

  const AdminFinancesScreen({super.key, required this.businessId});

  @override
  ConsumerState<AdminFinancesScreen> createState() =>
      _AdminFinancesScreenState();
}

class _AdminFinancesScreenState extends ConsumerState<AdminFinancesScreen> {
  String _selectedFilter = 'Esta semana';

  (DateTime, DateTime) _getDateRange() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Hoy':
        final start = DateTime(now.year, now.month, now.day);
        return (start, start.add(const Duration(days: 1)));
      case 'Este mes':
        return (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1),
        );
      case 'Este año':
        return (DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 1));
      default: // 'Esta semana'
        final weekday = now.weekday;
        final start = DateTime(now.year, now.month, now.day - (weekday - 1));
        return (start, start.add(const Duration(days: 7)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (start, end) = _getDateRange();
    final appointmentsAsync = ref.watch(
      adminFinancesProvider((widget.businessId, start, end)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Finanzas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterSelector(),
              const SizedBox(height: 24),
              appointmentsAsync.when(
                loading: () => const Center(child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )),
                error: (e, _) => _buildMainStats([]),
                data: (appointments) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainStats(appointments),
                    const SizedBox(height: 32),
                    _buildChartSection(appointments, start),
                    const SizedBox(height: 32),
                    _buildPaymentMethods(),
                    const SizedBox(height: 32),
                    _buildRecentTransactions(appointments),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Hoy', 'Esta semana', 'Este mes', 'Este año'].map((filter) {
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainStats(List<Appointment> appointments) {
    final active = appointments.where((a) => a.status != 'cancelled').toList();
    final total = active.fold<double>(0, (sum, a) => sum + a.totalPrice);
    final fmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingresos Totales',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(total),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubStat('Servicios', fmt.format(total), Icons.cut),
              _buildSubStat('Citas', '${active.length}', Icons.event_available),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection(List<Appointment> appointments, DateTime _) {
    final labels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final today = DateTime.now();
    final weekday = today.weekday;
    final weekStart = DateTime(today.year, today.month, today.day - (weekday - 1));

    // Calculate daily revenue for each day of the week starting at weekStart
    final dailyRevenue = List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      return appointments
          .where((a) =>
              a.status != 'cancelled' &&
              a.dateTime.year == day.year &&
              a.dateTime.month == day.month &&
              a.dateTime.day == day.day)
          .fold<double>(0, (sum, a) => sum + a.totalPrice);
    });

    final maxRevenue = dailyRevenue.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flujo de Ingresos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final day = weekStart.add(Duration(days: i));
              final isActive = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              final pct = maxRevenue > 0 ? dailyRevenue[i] / maxRevenue : 0.0;
              return _buildBar(pct, labels[i], isActive: isActive);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBar(double percentage, String label, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 130 * percentage,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métodos de Pago',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildPaymentCard(
                    'Efectivo', '0%', const Color(0xFF10B981))),
            const SizedBox(width: 16),
            Expanded(
                child: _buildPaymentCard(
                    'Tarjeta', '0%', const Color(0xFF3B82F6))),
            const SizedBox(width: 16),
            Expanded(
                child: _buildPaymentCard(
                    'Transf.', '0%', const Color(0xFFF59E0B))),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentCard(String label, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 8),
          Text(
            percentage,
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(List<Appointment> appointments) {
    final active = appointments.where((a) => a.status != 'cancelled').toList();
    final fmt = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFmt = DateFormat('d MMM, h:mm a', 'es');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transacciones Recientes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (active.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No hay transacciones recientes',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: active.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final appt = active[index];
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      color: Color(0xFF0284C7),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appt.serviceNames.join(', '),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${appt.professionalName} • ${dateFmt.format(appt.dateTime)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${fmt.format(appt.totalPrice)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
