import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _projectTypeController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _projectTypeController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProjectProvider>();

    final budgetText = _budgetController.text.trim();
    final budgetValue = budgetText.isEmpty ? null : double.tryParse(budgetText);

    final project = await provider.createProject(
      title: _titleController.text.trim(),
      projectType: _projectTypeController.text.trim().isEmpty
          ? null
          : _projectTypeController.text.trim(),
      budgetTarget: budgetValue,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;

    if (project != null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project berhasil dibuat')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.submitErrorMessage ?? 'Gagal membuat project'),
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Buat Project'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                            Icons.folder_special_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Mulai Project Baru',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Buat project untuk mengatur kebutuhan material, estimasi biaya, dan order secara bertahap.',
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
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
                          TextFormField(
                            controller: _titleController,
                            decoration: _inputDecoration(
                              label: 'Judul Project',
                              hint: 'Contoh: Kitchen Set Rumah A',
                              icon: Icons.title_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Judul project wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _projectTypeController,
                            decoration: _inputDecoration(
                              label: 'Tipe Project',
                              hint: 'Contoh: Kitchen Set, Wardrobe',
                              icon: Icons.category_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              label: 'Budget Target',
                              hint: 'Contoh: 10000000',
                              icon: Icons.account_balance_wallet_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }

                              final parsed = double.tryParse(value.trim());
                              if (parsed == null) {
                                return 'Budget harus berupa angka';
                              }

                              if (parsed < 0) {
                                return 'Budget tidak boleh negatif';
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
                              hint: 'Tambahkan catatan kebutuhan project',
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
                        onPressed: provider.isSubmitting ? null : _handleSubmit,
                        icon: provider.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(
                          provider.isSubmitting
                              ? 'Menyimpan...'
                              : 'Simpan Project',
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
          ],
        ),
      ),
    );
  }
}
