import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/business_providers.dart';
import '../widgets/content_stepper.dart';

class NewServiceFlow extends ConsumerStatefulWidget {
  final String businessId;
  const NewServiceFlow({super.key, required this.businessId});

  @override
  ConsumerState<NewServiceFlow> createState() => _NewServiceFlowState();
}

class _NewServiceFlowState extends ConsumerState<NewServiceFlow> {
  int _currentStep = 1;
  final int _totalSteps = 2;

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController(text: '30 min');

  bool _isPublishing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa los campos')),
        );
        return;
      }
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

      await repo.addService(widget.businessId, {
        'name': _nameController.text,
        'price': _priceController.text,
        'duration': _durationController.text,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Servicio agregado con éxito!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar servicio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentStepper(
      title: 'Nuevo servicio',
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      themeColor: AppColors.primary,
      onNext: _nextStep,
      onBack: _previousStep,
      nextButtonText:
          _currentStep == _totalSteps ? 'Agregar servicio' : 'Continuar',
      steps: [
        _buildInfoStep(),
        _buildPreviewStep(),
      ],
    );
  }

  Widget _buildInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField('Nombre del servicio', 'Ej: Corte de cabello + Barba',
            _nameController),
        const SizedBox(height: 20),
        _buildField('Precio', 'Ej: 25000', _priceController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _buildField('Duración estimada', 'Ej: 45 min', _durationController),
      ],
    );
  }

  Widget _buildField(
      String label, String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _buildPreviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirmar detalles del servicio',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.cut_outlined, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_nameController.text,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                        '\$${_priceController.text} · ${_durationController.text}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
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
