import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../material/providers/material_provider.dart';
import '../providers/project_provider.dart';

class AddProjectItemScreen extends StatefulWidget {
  final int projectId;

  const AddProjectItemScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<AddProjectItemScreen> createState() => _AddProjectItemScreenState();
}

class _AddProjectItemScreenState extends State<AddProjectItemScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedMaterialId;
  final _customNameController = TextEditingController();
  final _qtyNeededController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MaterialProvider>().fetchMaterials();
    });
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _qtyNeededController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMaterialId == null &&
        _customNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih material atau isi custom name'),
        ),
      );
      return;
    }

    final provider = context.read<ProjectProvider>();

    final success = await provider.addProjectItem(
      projectId: widget.projectId,
      materialId: _selectedMaterialId,
      customName: _customNameController.text.trim().isEmpty
          ? null
          : _customNameController.text.trim(),
      qtyNeeded: int.parse(_qtyNeededController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.submitErrorMessage ?? 'Gagal menambah item'),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
    );
  }

  String _formatPrice(double? value) {
    if (value == null) return 'Harga belum ada';
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final materialProvider = context.watch<MaterialProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Tambah Item Project'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: materialProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.22),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.inventory_2_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Tambah Kebutuhan Material',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pilih material dari katalog atau isi custom item jika material belum tersedia.',
                              style: TextStyle(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (materialProvider.errorMessage != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            materialProvider.errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            DropdownButtonFormField<int>(
                              value: _selectedMaterialId,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                label: 'Pilih Material',
                                hint: 'Pilih material dari katalog',
                                icon: Icons.layers_rounded,
                              ),
                              items: materialProvider.materials.map((material) {
                                return DropdownMenuItem<int>(
                                  value: material.id,
                                  child: Text(
                                    '${material.displayName} • ${_formatPrice(material.priceEstimate)}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMaterialId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    'atau',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _customNameController,
                              decoration: _inputDecoration(
                                label: 'Custom Name',
                                hint: 'Contoh: Handle custom / aksesoris lain',
                                icon: Icons.edit_note_rounded,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _qtyNeededController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                label: 'Qty Needed',
                                hint: 'Contoh: 10',
                                icon: Icons.add_shopping_cart_rounded,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Qty wajib diisi';
                                }
                                if (int.tryParse(value.trim()) == null) {
                                  return 'Qty harus berupa angka';
                                }
                                if (int.parse(value.trim()) < 1) {
                                  return 'Qty minimal 1';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 4,
                              decoration: _inputDecoration(
                                label: 'Catatan',
                                hint:
                                    'Contoh: warna, ukuran, kode, atau kebutuhan khusus',
                                icon: Icons.notes_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            iconColor: Colors.white,
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: projectProvider.isSubmitting
                              ? null
                              : _handleSubmit,
                          icon: projectProvider.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.playlist_add_rounded),
                          label: Text(
                            projectProvider.isSubmitting
                                ? 'Menambahkan...'
                                : 'Tambah Item',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
