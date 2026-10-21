import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/symptom_report.dart';
import '../../../services/auth_service.dart';

/// ============================================
/// TELA: RELATAR SINTOMAS (Supabase)
/// ============================================
class ReportSymptomsPage extends StatefulWidget {
  const ReportSymptomsPage({super.key});

  @override
  State<ReportSymptomsPage> createState() => _ReportSymptomsPageState();
}

class _ReportSymptomsPageState extends State<ReportSymptomsPage> {
  final _notesController = TextEditingController();
  final _authService = AuthService();

  final Set<String> _selectedSymptoms = {};
  final Set<String> _selectedDifficulties = {};

  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_selectedSymptoms.isEmpty &&
        _selectedDifficulties.isEmpty &&
        _notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marque pelo menos uma opção ou escreva uma observação'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final report = SymptomReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      symptoms: _selectedSymptoms.toList(),
      difficulties: _selectedDifficulties.toList(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final error = await _authService.saveSymptomToCloud(report);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Relato salvo com sucesso!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) AppRoutes.back(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Como você está se sentindo?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.back(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(icon: Icons.monitor_heart_outlined, title: 'Você sentiu algum sintoma?'),
              const SizedBox(height: 12),
              const Text('Marque os que se aplicam:', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SymptomOptions.symptoms.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return _OptionChip(
                    label: symptom,
                    isSelected: isSelected,
                    color: AppColors.error,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSymptoms.remove(symptom);
                        } else {
                          _selectedSymptoms.add(symptom);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              const _SectionTitle(icon: Icons.psychology_outlined, title: 'Teve alguma dificuldade?'),
              const SizedBox(height: 12),
              const Text('Marque as que se aplicam:', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SymptomOptions.difficulties.map((diff) {
                  final isSelected = _selectedDifficulties.contains(diff);
                  return _OptionChip(
                    label: diff,
                    isSelected: isSelected,
                    color: AppColors.warning,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDifficulties.remove(diff);
                        } else {
                          _selectedDifficulties.add(diff);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              const _SectionTitle(icon: Icons.notes_outlined, title: 'Observações (opcional)'),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Como você se sentiu hoje? Algo para contar ao nutricionista?'),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check),
                label: Text(_isSaving ? 'Salvando...' : 'Salvar relato'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isSaving ? null : () => AppRoutes.back(context),
                child: const Text('Cancelar'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _OptionChip({required this.label, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check, size: 16, color: color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 36, width: 36,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: AppTextStyles.h3)),
      ],
    );
  }
}