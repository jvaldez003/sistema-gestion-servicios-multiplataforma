import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/admin/presentation/providers/admin_providers.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/business_providers.dart';
import '../widgets/content_stepper.dart';

class NewPostFlow extends ConsumerStatefulWidget {
  final String businessId;
  const NewPostFlow({super.key, required this.businessId});

  @override
  ConsumerState<NewPostFlow> createState() => _NewPostFlowState();
}

class _NewPostFlowState extends ConsumerState<NewPostFlow> {
  int _currentStep = 1;
  final int _totalSteps = 3;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  String? _selectedServiceId;
  String _description = '';
  bool _isPublishing = false;

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 1 && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona al menos una foto')),
      );
      return;
    }
    if (_currentStep == 2 && _description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor agrega una descripción')),
      );
      return;
    }

    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _publish();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _publish() async {
    setState(() => _isPublishing = true);
    try {
      final repo = ref.read(businessRepositoryProvider);

      // Simulating image upload and getting a URL
      // In a real app, you'd upload _selectedImages to Firebase Storage here
      const mockUrl =
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&q=80&w=800';

      await repo.addPost(widget.businessId, {
        'title': 'Nueva publicación',
        'content': _description,
        'imageUrl': mockUrl,
        'serviceId': _selectedServiceId,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Publicación creada con éxito!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(adminServicesProvider);

    return ContentStepper(
      title: 'Nueva publicación',
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      themeColor: const Color(0xFFF97316),
      onNext: _nextStep,
      onBack: _previousStep,
      nextButtonText:
          _currentStep == _totalSteps ? 'Publicar en galería' : 'Continuar',
      steps: [
        // Step 1: Photos
        _buildPhotoStep(),
        // Step 2: Details
        _buildDetailsStep(servicesAsync),
        // Step 3: Preview
        _buildPreviewStep(servicesAsync),
      ],
    );
  }

  Widget _buildPhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona fotos para la galería',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _selectedImages.length + 1,
          itemBuilder: (context, index) {
            if (index == _selectedImages.length) {
              return GestureDetector(
                onTap: _pickImages,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        style: BorderStyle.solid),
                  ),
                  child: const Icon(Icons.add_a_photo_outlined,
                      color: AppColors.textSecondary),
                ),
              );
            }
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(_selectedImages[index].path),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImages.removeAt(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailsStep(
      AsyncValue<List<Map<String, dynamic>>> servicesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicio relacionado',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        servicesAsync.when(
          data: (services) => Wrap(
            spacing: 8,
            children: services.map((s) {
              final isSelected = _selectedServiceId == s['id'];
              return ChoiceChip(
                label: Text(s['name'] ?? ''),
                selected: isSelected,
                onSelected: (val) {
                  setState(() => _selectedServiceId = val ? s['id'] : null);
                },
                selectedColor: const Color(0xFFF3E8FF),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF9333EA)
                      : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF9333EA)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              );
            }).toList(),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Error al cargar servicios'),
        ),
        const SizedBox(height: 24),
        const Text(
          'Descripción del post',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 4,
          onChanged: (val) => setState(() => _description = val),
          decoration: InputDecoration(
            hintText:
                'Describe el trabajo, el servicio o añade una historia...',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewStep(
      AsyncValue<List<Map<String, dynamic>>> servicesAsync) {
    final selectedService = servicesAsync.value?.firstWhere(
      (s) => s['id'] == _selectedServiceId,
      orElse: () => {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vista previa del post',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.cut, color: Color(0xFFF97316), size: 24),
            const SizedBox(width: 12),
            Text(
              selectedService?['name'] ?? 'Sin servicio relacionado',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _description.isEmpty ? 'Sin descripción' : _description,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        if (_selectedImages.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              File(_selectedImages[0].path),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        if (_isPublishing)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
