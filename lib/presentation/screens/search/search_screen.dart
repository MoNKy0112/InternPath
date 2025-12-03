import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:internpath/domain/usecases/company_usecases.dart';
import 'package:internpath/domain/entities/experience.dart';
import 'package:internpath/domain/entities/company.dart';
import 'package:internpath/presentation/widgets/experience_card.dart';
import 'package:internpath/presentation/widgets/company_card.dart';
import 'package:internpath/presentation/widgets/app_scaffold.dart';

enum SearchMode { experiences, companies }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  Timer? _debounce;
  bool _loading = false;

  // resultados
  List<Experience> _experienceResults = [];
  List<Company> _companyResults = [];

  // caches auxiliares
  final Map<String, String> _companyNames =
      {}; // companyId -> name (para experiences)
  final Set<String> _pendingCompanyFetch = {};

  late SearchMode _mode;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _mode = SearchMode.experiences;
    _authProvider = context.read<AuthProvider>();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _setMode(SearchMode m) {
    if (_mode == m) return;
    setState(() {
      _mode = m;
      // limpiar resultados actuales al cambiar modo
      _experienceResults = [];
      _companyResults = [];
    });
    // re-ejecutar búsqueda con el texto actual
    _onQueryChanged(_ctrl.text);
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(q.trim());
    });
    setState(() {}); // para actualizar suffixIcon del TextField
  }

  Future<void> _performSearch(String q) async {
    if (q.isEmpty) {
      setState(() {
        _experienceResults = [];
        _companyResults = [];
      });
      return;
    }

    setState(() => _loading = true);
    try {
      if (_mode == SearchMode.experiences) {
        final expUse = context.read<ExperienceUseCases>();
        final userId = _authProvider.domainUser?.id ?? '';
        // usecase: searchExperiences(query)
        final list = await expUse.searchExperiences(userId, q, limit: 50);
        if (!mounted) return;
        setState(() {
          _experienceResults = list;
        });
        _fetchMissingCompanyNames(list);
      } else {
        final companyUse = context.read<CompanyUseCases>();
        // obtener lista (client-side filter) y filtrar por nombre / website / descripción
        final companies = await companyUse.getCompanies();
        final lower = q.toLowerCase();
        final filtered = companies.where((c) {
          final name = c.name.toLowerCase();
          final website = (c.website ?? '').toLowerCase();
          final desc = (c.description ?? '').toLowerCase();
          return name.contains(lower) ||
              website.contains(lower) ||
              desc.contains(lower);
        }).toList();
        if (!mounted) return;
        setState(() {
          _companyResults = filtered;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al buscar: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fetchMissingCompanyNames(List<Experience> list) {
    final missing = list
        .map((e) => e.companyId)
        .toSet()
        .where(
          (id) =>
              id.isNotEmpty &&
              !_companyNames.containsKey(id) &&
              !_pendingCompanyFetch.contains(id),
        )
        .toList();
    if (missing.isEmpty) return;
    for (final id in missing) {
      _pendingCompanyFetch.add(id);
    }
    final companyUse = context.read<CompanyUseCases>();
    Future.wait(
      missing.map((id) async {
        try {
          final c = await companyUse.getCompanyById(id);
          if (c != null) {
            _companyNames[id] = c.name;
          } else {
            _companyNames[id] = 'Empresa';
          }
        } catch (_) {
          _companyNames[id] = 'Empresa';
        } finally {
          _pendingCompanyFetch.remove(id);
        }
      }),
    ).then((_) {
      if (!mounted) return;
      setState(() {}); // refrescar para mostrar nombres
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        const SizedBox(height: 10),
        // Modo: botones Cargo / Empresa
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mode == SearchMode.experiences
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade200,
                    foregroundColor: _mode == SearchMode.experiences
                        ? Colors.white
                        : Colors.black87,
                    elevation: _mode == SearchMode.experiences ? 2 : 0,
                  ),
                  onPressed: () => _setMode(SearchMode.experiences),
                  child: const Text('Por cargo'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mode == SearchMode.companies
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade200,
                    foregroundColor: _mode == SearchMode.companies
                        ? Colors.white
                        : Colors.black87,
                    elevation: _mode == SearchMode.companies ? 2 : 0,
                  ),
                  onPressed: () => _setMode(SearchMode.companies),
                  child: const Text('Por empresa'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: _ctrl,
            onChanged: _onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: _mode == SearchMode.experiences
                  ? 'Buscar experiencias por cargo o descripción'
                  : 'Buscar empresas por nombre, sitio o descripción',
              suffixIcon: _ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _ctrl.clear();
                        _onQueryChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        if (_loading) const LinearProgressIndicator(),
        const SizedBox(height: 8),
        Expanded(child: _buildResultsView()),
      ],
    );

    return AppScaffold(title: 'Buscar', currentPageIndex: 1, child: body);
  }

  Widget _buildResultsView() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mode == SearchMode.experiences) {
      if (_experienceResults.isEmpty) {
        return Center(
          child: Text(
            _ctrl.text.isEmpty
                ? 'Escribe para buscar experiencias'
                : 'No se encontraron experiencias',
          ),
        );
      }
      return ListView.builder(
        itemCount: _experienceResults.length,
        itemBuilder: (context, i) {
          final e = _experienceResults[i];
          final companyName = _companyNames[e.companyId];
          return ExperienceCard(
            experience: e,
            companyName: companyName ?? 'Cargando...',
          );
        },
      );
    } else {
      if (_companyResults.isEmpty) {
        return Center(
          child: Text(
            _ctrl.text.isEmpty
                ? 'Escribe para buscar empresas'
                : 'No se encontraron empresas',
          ),
        );
      }
      return ListView.builder(
        itemCount: _companyResults.length,
        itemBuilder: (context, i) {
          final c = _companyResults[i];
          return CompanyCard(
            company: c,
            onTap: () => GoRouter.of(context).push('/company_detail/${c.id}'),
          );
        },
      );
    }
  }
}
