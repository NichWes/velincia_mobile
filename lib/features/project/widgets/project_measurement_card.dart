import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_measurement_provider.dart';

class ProjectMeasurementCard extends StatefulWidget {
  final int projectId;

  const ProjectMeasurementCard({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectMeasurementCard> createState() => _ProjectMeasurementCardState();
}

class _ProjectMeasurementCardState extends State<ProjectMeasurementCard> {
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = context.read<ProjectMeasurementProvider>();
      await provider.fetchMeasurements(widget.projectId);
      _fillControllers(provider);
    });
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _fillControllers(ProjectMeasurementProvider provider) {
    for (final item in provider.measurements) {
      if (item.keyName == 'length') {
        _lengthController.text = item.value.toStringAsFixed(0);
      } else if (item.keyName == 'width') {
        _widthController.text = item.value.toStringAsFixed(0);
      } else if (item.keyName == 'height') {
        _heightController.text = item.value.toStringAsFixed(0);
      }
    }
  }

  Future<void> _saveAll() async {
    final provider = context.read<ProjectMeasurementProvider>();

    final length = double.tryParse(_lengthController.text.trim());
    final width = double.tryParse(_widthController.text.trim());
    final height = double.tryParse(_heightController.text.trim());

    if (length == null && width == null && height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi minimal satu ukuran')),
      );
      return;
    }

    bool ok = true;

    if (length != null) {
      ok = await provider.saveMeasurement(
        projectId: widget.projectId,
        keyName: 'length',
        value: length,
      );
    }

    if (width != null && ok) {
      ok = await provider.saveMeasurement(
        projectId: widget.projectId,
        keyName: 'width',
        value: width,
      );
    }

    if (height != null && ok) {
      ok = await provider.saveMeasurement(
        projectId: widget.projectId,
        keyName: 'height',
        value: height,
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Ukuran project berhasil disimpan'
            : provider.errorMessage ?? 'Gagal simpan ukuran'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectMeasurementProvider>(
      builder: (context, provider, _) {
        final summary = provider.summary;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ukuran Project',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Isi ukuran dasar untuk membantu estimasi kebutuhan material.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (provider.isLoading)
                const LinearProgressIndicator()
              else ...[
                Row(
                  children: [
                    Expanded(child: _numberField('Panjang', _lengthController)),
                    const SizedBox(width: 10),
                    Expanded(child: _numberField('Lebar', _widthController)),
                    const SizedBox(width: 10),
                    Expanded(child: _numberField('Tinggi', _heightController)),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _summaryChip('Luas Lantai',
                        summary.areaM2 == null ? '-' : '${summary.areaM2} m²'),
                    _summaryChip(
                        'Luas Dinding',
                        summary.wallAreaM2 == null
                            ? '-'
                            : '${summary.wallAreaM2} m²'),
                    _summaryChip(
                        'Volume',
                        summary.volumeM3 == null
                            ? '-'
                            : '${summary.volumeM3} m³'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      iconColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: provider.isSaving ? null : _saveAll,
                    icon: const Icon(Icons.straighten_rounded),
                    label: Text(
                        provider.isSaving ? 'Menyimpan...' : 'Simpan Ukuran'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'cm',
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _summaryChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
