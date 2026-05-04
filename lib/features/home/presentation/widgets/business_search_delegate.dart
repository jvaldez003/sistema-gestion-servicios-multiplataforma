import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/business.dart';

class BusinessSearchDelegate extends SearchDelegate<Business?> {
  final List<Business> businesses;

  BusinessSearchDelegate({required this.businesses});

  @override
  String get searchFieldLabel => 'Buscar negocio...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredBusinesses = businesses.where((business) {
      final nameLower = business.name.toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();

    if (query.isNotEmpty && filteredBusinesses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'No se pudo encontrar el negocio que buscas',
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBusinesses.length,
      itemBuilder: (context, index) {
        final business = filteredBusinesses[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: business.avatarUrl.isNotEmpty 
                ? NetworkImage(business.avatarUrl) 
                : (business.imageUrl.isNotEmpty ? NetworkImage(business.imageUrl) : null),
            child: business.avatarUrl.isEmpty && business.imageUrl.isEmpty 
                ? const Icon(Icons.storefront) 
                : null,
          ),
          title: Text(business.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          subtitle: Text(business.category, style: AppTypography.bodySmall),
          onTap: () {
            close(context, business);
            context.push('/business/${business.id}', extra: business);
          },
        );
      },
    );
  }
}
