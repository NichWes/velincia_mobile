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

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final materialProvider = context.watch<MaterialProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Item Project'),
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
                      DropdownButtonFormField<int>(
                        value: _selectedMaterialId,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Material',
                          border: OutlineInputBorder(),
                        ),
                        items: materialProvider.materials.map((material) {
                          return DropdownMenuItem<int>(
                            value: material.id,
                            child: Text(material.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMaterialId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _customNameController,
                        decoration: const InputDecoration(
                          labelText: 'Custom Name (opsional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _qtyNeededController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Qty Needed',
                          border: OutlineInputBorder(),
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
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Catatan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: projectProvider.isSubmitting
                              ? null
                              : _handleSubmit,
                          child: projectProvider.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Tambah Item'),
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
