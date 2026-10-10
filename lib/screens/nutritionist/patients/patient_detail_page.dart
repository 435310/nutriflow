import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/meal.dart';
import '../../../models/patient_detail.dart';
import '../../../widgets/mini_weight_chart.dart';
import '../../../widgets/patient_detail_section.dart';
import '../../../widgets/user_avatar.dart';

/// ============================================
/// TELA: PERFIL DO PACIENTE (visão do nutricionista)
/// ============================================
class PatientDetailPage extends StatefulWidget {
  const PatientDetailPage({super.key});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final PatientDetail _detail = PatientDetail.mock();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature em breve'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsBottomSheet(
        onEdit: () {
          Navigator.pop(context);
          _showComingSoon('Editar paciente');
        },
        onArchive: () {
          Navigator.pop(context);
          _showComingSoon('Arquivar paciente');
        },
        onDelete: () {
          Navigator.pop(context);
          _showComingSoon('Excluir paciente');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _detail.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(profile.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.back(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // CABEÇALHO
                _buildHeader(profile),

                const SizedBox(height: 28),

                // RESUMO
                PatientDetailSection(
                  icon: Icons.insights_outlined,
                  title: 'Resumo',
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Peso atual',
                        profile.currentWeightKg != null
                            ? '${profile.currentWeightKg!.toStringAsFixed(1)} kg'
                            : '—',
                      ),
                      _buildInfoRow(
                        'Variação',
                        profile.weightDelta != null
                            ? '${profile.weightDelta! < 0 ? '▼' : '▲'} ${profile.weightDelta!.abs().toStringAsFixed(1)} kg'
                            : '—',
                        valueColor: profile.weightDelta == null
                            ? null
                            : profile.weightDelta! < 0
                                ? AppColors.success
                                : AppColors.warning,
                      ),
                      _buildInfoRow(
                        'Meta',
                        profile.goalWeightKg != null
                            ? '${profile.goalWeightKg!.toStringAsFixed(1)} kg'
                            : '—',
                      ),
                      _buildInfoRow(
                        'IMC',
                        profile.bmi != null
                            ? '${profile.bmi!.toStringAsFixed(1)} (${profile.bmiCategory})'
                            : '—',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // EVOLUÇÃO DE PESO
                PatientDetailSection(
                  icon: Icons.show_chart,
                  title: 'Evolução de peso',
                  trailing: TextButton(
                    onPressed: () => _showComingSoon('Ver gráfico completo'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Ver mais'),
                  ),
                  child: Column(
                    children: [
                      MiniWeightChart(
                        entries: _detail.weightHistory,
                        height: 70,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${_detail.weightHistory.length} registros',
                            style: AppTextStyles.caption,
                          ),
                          const Spacer(),
                          Text(
                            'Últimos 90 dias',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ÚLTIMAS REFEIÇÕES
                PatientDetailSection(
                  icon: Icons.restaurant_menu,
                  title: 'Últimas refeições',
                  trailing: TextButton(
                    onPressed: () => _showComingSoon('Ver todas'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Ver todas'),
                  ),
                  child: _detail.recentMeals.isEmpty
                      ? _buildEmptyInfo('Nenhuma refeição registrada')
                      : Column(
                          children: _detail.recentMeals
                              .map((meal) => _buildMealRow(meal))
                              .toList(),
                        ),
                ),

                const SizedBox(height: 16),

                // ÚLTIMOS EXAMES
                PatientDetailSection(
                  icon: Icons.description_outlined,
                  title: 'Últimos exames',
                  trailing: TextButton(
                    onPressed: () => _showComingSoon('Ver todos'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Ver todos'),
                  ),
                  child: _detail.recentExams.isEmpty
                      ? _buildEmptyInfo('Nenhum exame enviado')
                      : Column(
                          children: _detail.recentExams
                              .map((exam) => _buildExamRow(exam))
                              .toList(),
                        ),
                ),

                const SizedBox(height: 16),

                // ÚLTIMAS MENSAGENS
                PatientDetailSection(
                  icon: Icons.chat_bubble_outline,
                  title: 'Últimas mensagens',
                  trailing: TextButton(
                    onPressed: () => _showComingSoon('Ver conversa'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Ver conversa'),
                  ),
                  child: _detail.recentMessages.isEmpty
                      ? _buildEmptyInfo('Nenhuma mensagem')
                      : Column(
                          children: _detail.recentMessages
                              .map((msg) => _buildMessageRow(msg))
                              .toList(),
                        ),
                ),

                const SizedBox(height: 24),

                // BOTÕES DE AÇÃO
                ElevatedButton.icon(
                  onPressed: () => _showComingSoon('Enviar mensagem'),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Enviar mensagem'),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () => _showComingSoon('Plano alimentar'),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Ver plano alimentar'),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic profile) {
    return Column(
      children: [
        UserAvatar(
          name: profile.name,
          size: UserAvatarSize.large,
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Evoluindo · 2h atrás',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealRow(Meal meal) {
    final time =
        '${meal.dateTime.hour.toString().padLeft(2, '0')}:${meal.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(meal.type.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.type.label,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${meal.foods.length} alimento${meal.foods.length > 1 ? 's' : ''}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(time, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildExamRow(PatientExam exam) {
    final isPending = exam.status == ExamStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: (isPending ? AppColors.warning : AppColors.success)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPending ? Icons.pending_outlined : Icons.check_circle_outline,
              size: 18,
              color: isPending ? AppColors.warning : AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  exam.status.label,
                  style: AppTextStyles.caption.copyWith(
                    color: isPending ? AppColors.warning : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          Text(exam.timeAgo, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildMessageRow(PatientMessage msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            msg.fromPatient
                ? Icons.person_outline
                : Icons.medical_services_outlined,
            size: 20,
            color: msg.fromPatient
                ? AppColors.textSecondary
                : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.fromPatient ? 'Paciente' : 'Você',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: msg.fromPatient
                        ? AppColors.textSecondary
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  msg.content,
                  style: AppTextStyles.body.copyWith(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(msg.timeAgo, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildEmptyInfo(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: AppTextStyles.caption,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _OptionsBottomSheet extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _OptionsBottomSheet({
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Editar dados'),
            onTap: onEdit,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Arquivar paciente'),
            onTap: onArchive,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
            ),
            title: const Text(
              'Excluir paciente',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}