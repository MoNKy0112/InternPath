import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/domain/entities/company.dart';
import 'package:internpath/domain/entities/experience.dart';
import 'package:internpath/domain/usecases/company_usecases.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:internpath/presentation/widgets/app_scaffold.dart';
import 'package:internpath/presentation/widgets/experience_card.dart';
import 'package:provider/provider.dart';

class ExperienceList extends StatefulWidget {
  const ExperienceList({super.key, required this.isPersonalExperienceList});

  final bool isPersonalExperienceList;

  @override
  State<ExperienceList> createState() => _ExperienceListState();
}

class _ExperienceListState extends State<ExperienceList> {
  late ExperienceUseCases _experienceUseCases;

  final List<Experience> experiences = [];
  bool isLoading = false;
  Experience? lastExperience;
  AuthProvider get _authProvider => context.read<AuthProvider>();
  Map<String, Company> companiesById = {};
  bool companiesLoaded = false;

  // Nuevas variables para controlar la carga incremental y evitar peticiones rápidas
  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;
  DateTime? _lastLoadMoreAttempt;
  final Duration _loadMoreCooldown = const Duration(milliseconds: 800);

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    if (_authProvider.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return;
    }
    _experienceUseCases = context.read<ExperienceUseCases>();

    if (!companiesLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCompanies();
      });
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // solo intentar cargar más si el usuario está scrolleando hacia abajo
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // comprobar dirección del scroll (ScrollController no expone directamente, usamos delta)
    // aquí asumimos que queremos cargar cuando el usuario alcance cercano al final y haya desplazamiento posible
    if (pos.pixels >= pos.maxScrollExtent - 120) {
      final now = DateTime.now();
      if (_lastLoadMoreAttempt != null &&
          now.difference(_lastLoadMoreAttempt!) < _loadMoreCooldown) {
        return; // cooldown para evitar ráfagas
      }
      _lastLoadMoreAttempt = now;

      if (!_hasMore || isLoading) return;
      _loadExperiences(_authProvider.currentUser!.uid, loadMore: true);
    }
  }

  Future<void> _loadExperiences(String userId, {bool loadMore = false}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final newExperiences = widget.isPersonalExperienceList
          ? await _experienceUseCases.getExperiencesByUserId(
              userId,
              lastExperience: loadMore ? lastExperience : null,
              limit: _pageSize,
            )
          : await _experienceUseCases.getAllExperiences(
              excludeUserId: userId,
              lastExperience: loadMore ? lastExperience : null,
              limit: _pageSize,
            );

      if (!mounted) return;

      setState(() {
        if (loadMore) {
          experiences.addAll(newExperiences);
        } else {
          experiences
            ..clear()
            ..addAll(newExperiences);
        }
        if (newExperiences.isNotEmpty) {
          lastExperience = newExperiences.last;
        }
        // si recibimos menos que el tamaño de página, asumimos que no hay más por ahora
        _hasMore = newExperiences.length == _pageSize;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading experiences: $e')));
    }
  }

  Future<void> _loadCompanies() async {
    final companyUseCases = context.read<CompanyUseCases>();
    final companies = await companyUseCases.getCompanies();

    companiesById = {for (var c in companies) c.id: c};

    setState(() {
      companiesLoaded = true;
    });
  }

  Future<void> _handleRefresh() async {
    // al refrescar permitimos volver a intentar cargar más en caso de que haya nuevas
    _hasMore = true;
    lastExperience = null;
    await _loadExperiences(
      context.read<AuthProvider>().currentUser!.uid,
      loadMore: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!companiesLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      // evita redirección automática repetida
      return const SizedBox.shrink();
    }

    // Cargar experiencias si aún no hay
    if (experiences.isEmpty && !isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadExperiences(user.uid, loadMore: false);
      });
    }

    return AppScaffold(
      title: widget.isPersonalExperienceList
          ? "Mis Experiencias"
          : "Experiencias",
      currentPageIndex: widget.isPersonalExperienceList ? 2 : 0,
      scaffoldExtras: {
        'floatingActionButton': FloatingActionButton(
          onPressed: () {
            context.go('/experiences/create');
          },
          child: const Icon(Icons.add),
        ),
        'floatingActionButtonLocation': FloatingActionButtonLocation.endFloat,
      },
      child: RefreshIndicator(
        // ajuste visual del indicador
        displacement: 28,
        edgeOffset: 4,
        onRefresh: _handleRefresh,
        child: ListView.builder(
          controller: _scrollController,
          physics:
              const AlwaysScrollableScrollPhysics(), // <- permite pull-to-refresh aunque la lista no ocupe toda la pantalla
          itemCount: experiences.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < experiences.length) {
              return ExperienceCard(
                experience: experiences[index],
                companyName:
                    companiesById[experiences[index].companyId]?.name ??
                    'Empresa Desconocida',
              );
            } else {
              // indicador de carga final; si no hay más, no se muestra por el itemCount
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}
