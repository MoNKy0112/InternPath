import 'package:flutter/material.dart';
import 'package:internpath/domain/entities/company.dart';
import 'package:internpath/domain/usecases/company_usecases.dart';
import 'package:internpath/domain/usecases/experience_usecases.dart';
import 'package:internpath/presentation/widgets/app_scaffold.dart';
import 'package:internpath/presentation/widgets/experience_card.dart';
import 'package:internpath/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CompanyDetailScreen extends StatefulWidget {
  final String companyId;
  const CompanyDetailScreen({super.key, required this.companyId});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  Company? _company;
  bool _loading = true;
  bool _deleting = false;
  List<dynamic> _experiences = [];
  bool _loadingExperiences = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompany();
      _loadExperiences();
    });
  }

  Future<void> _loadCompany() async {
    setState(() => _loading = true);
    try {
      final usecases = context.read<CompanyUseCases>();
      final c = await usecases.getCompanyById(widget.companyId);
      if (!mounted) return;
      setState(() => _company = c);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando empresa: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadExperiences() async {
    setState(() => _loadingExperiences = true);
    try {
      final expUse = context.read<ExperienceUseCases>();
      final list = await expUse.getExperiencesByCompanyId(
        widget.companyId,
        limit: 20,
      );
      if (!mounted) return;
      setState(() => _experiences = list);
    } catch (_) {
      // silencio en caso de error: no bloquear la vista principal
    } finally {
      if (mounted) setState(() => _loadingExperiences = false);
    }
  }

  Future<void> _confirmAndDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar empresa'),
        content: const Text(
          '¿Seguro que deseas eliminar esta empresa? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _deleting = true);
    try {
      await context.read<CompanyUseCases>().deleteCompany(widget.companyId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Empresa eliminada')));
      // volver atrás
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        GoRouter.of(context).go('/');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _edit() {
    context.push('/admin/companies/edit/${widget.companyId}');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isModder = auth.isModder;

    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : _company == null
        ? Center(
            child: Text(
              'Empresa no encontrada',
              style: TextStyle(color: Colors.grey[700]),
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: logo + name + actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                        image: _company!.logoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_company!.logoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _company!.logoUrl == null
                          ? Center(
                              child: Text(
                                _company!.name.isNotEmpty
                                    ? _company!.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.black54,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _company!.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_company!.website != null &&
                              _company!.website!.isNotEmpty)
                            Text(
                              _company!.website!,
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                          const SizedBox(height: 8),
                          if (_company!.description != null &&
                              _company!.description!.isNotEmpty)
                            Text(
                              _company!.description!,
                              style: TextStyle(color: Colors.grey.shade800),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Volver',
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            if (Navigator.canPop(context))
                              Navigator.pop(context);
                            else
                              GoRouter.of(context).go('/');
                          },
                        ),
                        const SizedBox(height: 6),
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit, color: Colors.grey),
                          onPressed: isModder ? _edit : null,
                        ),
                        const SizedBox(height: 6),
                        IconButton(
                          tooltip: 'Eliminar',
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: isModder && !_deleting
                              ? _confirmAndDelete
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Detalles',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_company!.website ?? '-')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_company!.description ?? '-')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Experiencias relacionadas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _loadingExperiences
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _experiences.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: Text(
                            'No hay experiencias para esta empresa',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    : Column(
                        children: _experiences.map((e) {
                          // ExperienceCard espera Experience y companyName; si e es Experience o Map, adaptamos
                          return Builder(
                            builder: (ctx) {
                              try {
                                return ExperienceCard(
                                  experience: e as dynamic,
                                  companyName: _company!.name,
                                );
                              } catch (_) {
                                return const SizedBox.shrink();
                              }
                            },
                          );
                        }).toList(),
                      ),
              ],
            ),
          );

    return AppScaffold(
      title: _company?.name ?? 'Empresa',
      currentPageIndex: 0,
      scaffoldExtras: {},
      child: content,
    );
  }
}
