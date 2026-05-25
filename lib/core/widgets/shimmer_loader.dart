import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

// ─── Base shimmer box ────────────────────────────────────────────────────────

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ─── Shimmer wrapper ─────────────────────────────────────────────────────────

class _ShimmerWrap extends StatelessWidget {
  final Widget child;

  const _ShimmerWrap({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.surfaceVariantDark : const Color(0xFFE2E8F0),
      highlightColor: isDark ? AppColors.borderDark : const Color(0xFFF8FAFC),
      child: child,
    );
  }
}

// ─── Business card shimmer ───────────────────────────────────────────────────

class BusinessCardShimmer extends StatelessWidget {
  const BusinessCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ShimmerWrap(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFE2E8F0),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 140, height: 14, borderRadius: 6),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 100, height: 11, borderRadius: 6),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ShimmerBox(width: 60, height: 24, borderRadius: 12),
                      const SizedBox(width: 8),
                      ShimmerBox(width: 80, height: 24, borderRadius: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Appointment shimmer ─────────────────────────────────────────────────────

class AppointmentShimmer extends StatelessWidget {
  const AppointmentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _ShimmerWrap(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            ShimmerBox(width: 52, height: 52, borderRadius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 140, height: 11, borderRadius: 6),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 80, height: 20, borderRadius: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Post shimmer ────────────────────────────────────────────────────────────

class PostShimmer extends StatelessWidget {
  const PostShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ShimmerWrap(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ShimmerBox(width: 40, height: 40, borderRadius: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 120, height: 13, borderRadius: 6),
                      const SizedBox(height: 6),
                      ShimmerBox(width: 80, height: 11, borderRadius: 6),
                    ],
                  ),
                ],
              ),
            ),
            // Image
            Container(
              height: 200,
              color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFE2E8F0),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 13, borderRadius: 6),
                  const SizedBox(height: 8),
                  ShimmerBox(width: 200, height: 13, borderRadius: 6),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ShimmerBox(width: 60, height: 32, borderRadius: 16),
                      const SizedBox(width: 10),
                      ShimmerBox(width: 60, height: 32, borderRadius: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Generic list shimmer ────────────────────────────────────────────────────

class ListShimmer extends StatelessWidget {
  final int count;
  final Widget Function() itemBuilder;

  const ListShimmer({
    super.key,
    required this.count,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => itemBuilder()),
    );
  }
}
