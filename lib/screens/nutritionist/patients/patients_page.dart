import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/nutritionist_dashboard.dart';
import '../../../models/patient_filter.dart';
import '../../../widgets/patient_filter_chips.dart';
import '../../../widgets/patient_list_item.dart';

/// ============================================
/// TELA: LISTA DE PACIENTES DO NUTRICIONISTA
/// ============================================
class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final _searchController = TextEditingController();

  PatientFilter _selectedFilter = PatientFilter.all;
  PatientSort _selectedSort = PatientSort.lastActivity;

  late List<PatientSummary> _allPatients;

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
    _searchController.addListener(() => setState(() {}));
    _allPatients = _buildMockPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ============================================
  // MOCK DE PACIENTES
  // ============================================
  List<PatientSummary> _buildMockPatients() {
    final now = DateTime.now();
    return [
      PatientSummary(
        id: '1',
        name: 'Maria Silva',
        status: PatientStatus.evolving,
        lastActivity: 'Atualizou peso',
        lastActivityTime: now.subtract(const Duration(hours: 2)),
      ),
      PatientSummary(
        id: '2',
        name: 'João Pedro Santos',
        status: PatientStatus.attention,
        lastActivity: 'Enviou exame',
        lastActivityTime: now.subtract(const Duration(hours: 5)),
      ),
      PatientSummary(
        id: '3',
        name: 'Carlos Eduardo Souza',
        status: PatientStatus.noInteraction,
        lastActivity: 'Sem interação',
        lastActivityTime: now.subtract(const Duration(days: 8)),
      ),
      PatientSummary(
        id: '4',
        name: 'Ana Costa',
        status: PatientStatus.evolving,
        lastActivity: 'Registrou refeição',
        lastActivityTime: now.subtract(const Duration(hours: 1)),
      ),
      PatientSummary(
        id: '5',
        name: 'Beatriz Almeida',
        status: PatientStatus.attention,
        lastActivity: 'Poucos registros',
        lastActivityTime: now.subtract(const Duration(days: 3)),
      ),
      PatientSummary(
        id: '6',
        name: 'Rafael Lima',
        status: PatientStatus.evolving,
        lastActivity: 'Meta atingida',
        lastActivityTime: now.subtract(const Duration(minutes: 30)),
      ),
      PatientSummary(
        id: '7',
        name: 'Fernanda Oliveira',
        status: PatientStatus.evolving,
        lastActivity: 'Fez check-in',
        lastActivityTime: now.subtract(const Duration(hours: 4)),
      ),
      PatientSummary(
        id: '8',
        name: 'Gustavo Henrique',
        status: PatientStatus.attention,
        lastActivity: 'Atrasou refeição',
        lastActivityTime: now.subtract(const Duration(days: 2)),
      ),
      PatientSummary(
        id: '9',
        name: 'Helena Martins',
        status: PatientStatus.noInteraction,
        lastActivity: 'Sem interação',
        lastActivityTime: now.subtract(const Duration(days: 12)),
      ),
      PatientSummary(
        id: '10',
        name: 'Igor Pereira',
        status: PatientStatus.evolving,
        lastActivity: 'Registrou jantar',
        lastActivityTime: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }

  // ============================================
  // CONTAGEM POR FILTRO
  // ============================================
  Map<PatientFilter, int> get _filterCounts {
    return {
      PatientFilter.all: _allPatients.length,
      PatientFilter.evolving: _allPatients
          .where((p) => p.status == PatientStatus.evolving)
          .length,
      PatientFilter.attention: _allPatients
          .where((p) => p.status == PatientStatus.attention)
          .length,
      PatientFilter.noInteraction: _allPatients
          .where((p) => p.status == PatientStatus.noInteraction)
          .length,
    };
  }

  List<PatientSummary> get _filteredPatients {
    return filterAndSortPatients(
      patients: _allPatients,
      filter: _selectedFilter,
      sort: _selectedSort,
      searchQuery: _searchController.text,
    );
  }

  Future<void> _showSortMenu() async {
    final selected = await showModalBottomSheet<PatientSort>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortBottomSheet(current: _selectedSort),
    );

    if (selected != null) {
      setState(() {
        _selectedSort = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final patients = _filteredPatients;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pacientes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRoutes.back(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            children: [
              // ============================================
              // ÁREA FIXA (busca + filtros + ordenação)
              // ============================================
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 14),
                    PatientFilterChips(
                      selected: _selectedFilter,
                      counts: _filterCounts,
                      onChanged: (filter) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${patients.length} paciente${patients.length != 1 ? 's' : ''} encontrado${patients.length != 1 ? 's' : ''}',
                            style: AppTextStyles.caption,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showSortMenu,
                          icon: const Icon(Icons.sort, size: 16),
                          label: Text(
                            _selectedSort.label,
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ============================================
              // LISTA DE PACIENTES
              // ============================================
              Expanded(
                child: patients.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          final patient = patients[index];
                          return PatientListItem(
                            patient: patient,
                            onTap: () {
                              AppRoutes.go(
                                context,
                                AppRoutes.nutritionistPatientDetail,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Novo paciente em breve'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Novo paciente'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar paciente...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => _searchController.clear(),
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                hasSearch ? Icons.search_off : Icons.people_outline,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch
                  ? 'Nenhum paciente encontrado'
                  : 'Nenhum paciente neste filtro',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Tente buscar por outro nome.'
                  : 'Tente outro filtro ou cadastre um novo paciente.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// BOTTOM SHEET: ORDENAÇÃO
// ============================================
class _SortBottomSheet extends StatelessWidget {
  final PatientSort current;

  const _SortBottomSheet({required this.current});

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text('Ordenar por', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          ...PatientSort.values.map((sort) {
            final isSelected = sort == current;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              title: Text(
                sort.label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
              onTap: () => Navigator.pop(context, sort),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}