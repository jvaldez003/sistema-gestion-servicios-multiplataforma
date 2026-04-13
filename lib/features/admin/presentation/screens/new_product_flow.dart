import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:sistema_gestion_servicios_multiplataforma/features/home/presentation/providers/business_providers.dart';
import '../widgets/content_stepper.dart';

class NewProductFlow extends ConsumerStatefulWidget {
  final String businessId;
  final Map<String, dynamic>? existingProduct;

  const NewProductFlow({
    super.key, 
    required this.businessId,
    this.existingProduct,
  });

  @override
  ConsumerState<NewProductFlow> createState() => _NewProductFlowState();
}

class _NewProductFlowState extends ConsumerState<NewProductFlow> {
  int _currentStep = 1;
  final int _totalSteps = 3;

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descController;

  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameController = TextEditingController(text: p?['name']?.toString() ?? '');
    _priceController = TextEditingController(text: p?['price']?.toString() ?? '');
    _stockController = TextEditingController(text: p?['stock']?.toString() ?? '');
    _descController = TextEditingController(text: p?['description']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 1 && _selectedImage == null && widget.existingProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor selecciona una foto del producto')),
      );
      return;
    }
    if (_currentStep == 2) {
      if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor completa los campos obligatorios')),
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
      final isUpdating = widget.existingProduct != null;

      String finalImageUrl = widget.existingProduct?['imageUrl'] ?? '';

      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final mimeType = _selectedImage!.mimeType ?? 'image/jpeg';
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final path = 'businesses/${widget.businessId}/products/$fileName';
        
        finalImageUrl = await repo.uploadImage(path, bytes, mimeType);
      }

      final productData = {
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'stock': int.tryParse(_stockController.text) ?? 0,
        'description': _descController.text,
        'imageUrl': finalImageUrl.isNotEmpty ? finalImageUrl : null,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (isUpdating) {
        await repo.updateProduct(widget.businessId, widget.existingProduct!['id'], productData);
      } else {
        productData['createdAt'] = DateTime.now().toIso8601String();
        await repo.addProduct(widget.businessId, productData);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isUpdating ? '¡Producto actualizado!' : '¡Producto agregado con éxito!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar producto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = widget.existingProduct != null;
    return ContentStepper(
      title: isUpdating ? 'Editar producto' : 'Nuevo producto',
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      themeColor: const Color(0xFFC084FC),
      onNext: _nextStep,
      onBack: _previousStep,
      nextButtonText:
          _currentStep == _totalSteps 
            ? (isUpdating ? 'Guardar cambios' : 'Agregar al catálogo') 
            : 'Continuar',
      steps: [
        // Step 1: Photos
        _buildPhotoStep(),
        // Step 2: Info
        _buildInfoStep(),
        // Step 3: Preview
        _buildPreviewStep(),
      ],
    );
  }

  Widget _buildPhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto del producto',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: kIsWeb
                        ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                        : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 48, color: Color(0xFFC084FC)),
                      SizedBox(height: 12),
                      Text('Toca para seleccionar foto',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField('Nombre del producto', 'Ej: Pomada Fijadora Premium',
            _nameController),
        const SizedBox(height: 20),
        _buildField('Precio (COP)', 'Ej: 35000', _priceController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _buildField('Stock disponible', 'Ej: 20', _stockController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        _buildField('Descripción', 'Describe el producto...', _descController,
            maxLines: 3),
      ],
    );
  }

  Widget _buildField(
      String label, String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
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
          'Vista previa del producto',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_nameController.text,
                  style: AppTypography.titleLarge
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('\$${_priceController.text}',
                  style: const TextStyle(
                      color: Color(0xFFC084FC),
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 12),
              Text(
                  _descController.text.isEmpty
                      ? 'Sin descripción'
                      : _descController.text,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text('Stock: ${_stockController.text}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_selectedImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: kIsWeb
                ? Image.network(_selectedImage!.path,
                    width: double.infinity, height: 150, fit: BoxFit.cover)
                : Image.file(File(_selectedImage!.path),
                    width: double.infinity, height: 150, fit: BoxFit.cover),
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
