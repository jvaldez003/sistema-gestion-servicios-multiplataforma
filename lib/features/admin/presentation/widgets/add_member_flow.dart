import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistema_gestion_servicios_multiplataforma/core/theme/app_colors.dart';
import 'package:sistema_gestion_servicios_multiplataforma/core/theme/app_typography.dart';

class AddMemberFlow extends StatefulWidget {
  final String businessId;
  const AddMemberFlow({super.key, required this.businessId});

  @override
  State<AddMemberFlow> createState() => _AddMemberFlowState();
}

class _AddMemberFlowState extends State<AddMemberFlow> {
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _commissionController = TextEditingController(text: '50');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  Future<void> _addMember() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('businesses')
          .doc(widget.businessId)
          .collection('team')
          .add({
        'name': _nameController.text.trim(),
        'role': _roleController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'commission': int.tryParse(_commissionController.text.trim()) ?? 50,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Agregar miembro',
                    style:
                        AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child:
                      const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Name
            _buildLabel('Nombre completo *'),
            const SizedBox(height: 6),
            _buildTextField(_nameController, 'Ej. Carlos Méndez'),
            const SizedBox(height: 16),

            // Role
            _buildLabel('Rol / cargo'),
            const SizedBox(height: 6),
            _buildTextField(_roleController, 'Ej. Barbero Senior'),
            const SizedBox(height: 16),

            // Email
            _buildLabel('Correo electrónico'),
            const SizedBox(height: 6),
            _buildTextField(_emailController, 'correo@ejemplo.com',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),

            // Phone
            _buildLabel('Teléfono'),
            const SizedBox(height: 6),
            _buildTextField(_phoneController, '+57 300 000 0000',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),

            // Commission
            _buildLabel('Comisión (%)'),
            const SizedBox(height: 6),
            _buildTextField(_commissionController, '50',
                keyboardType: TextInputType.number),
            const SizedBox(height: 28),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addMember,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Agregar al equipo',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87));
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }
}
