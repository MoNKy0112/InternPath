import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internpath/domain/entities/request.dart';
import 'package:internpath/domain/usecases/request_usecases.dart';
import 'package:internpath/domain/usecases/auth_usecases.dart';
import 'package:internpath/presentation/widgets/request_card.dart';
import 'package:internpath/presentation/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class RequestListScreen extends StatefulWidget {
  const RequestListScreen({super.key});

  @override
  State<RequestListScreen> createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  static const int pageSize = 20;

  final ScrollController _scrollController = ScrollController();

  // todas las requests obtenidas del servidor (se filtran/paginan localmente)
  final List<Request> _allRequests = [];
  final List<Request> _items = [];

  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 0;

  // filtros y orden
  RequestType? _filterType;
  RequestStatus? _filterStatus;
  String? _filterUserId;
  bool _sortByDateDesc = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // carga inicial real
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllRequests());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAllRequests() async {
    setState(() {
      _isRefreshing = true;
      _page = 0;
      _hasMore = true;
    });

    try {
      final usecases = context.read<RequestUseCases>();
      final list = await usecases
          .getPendingRequests(); // ajustar si quieres otro endpoint
      if (!mounted) return;
      setState(() {
        _allRequests
          ..clear()
          ..addAll(list);
      });

      // preparar página 0
      _applyFiltersAndSetPage(0, replace: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando solicitudes: $e')));
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _applyFiltersAndSetPage(int page, {bool replace = false}) {
    // aplicar filtros y orden sobre _allRequests
    final filtered = _allRequests.where((r) {
      if (_filterType != null && r.type != _filterType) return false;
      if (_filterStatus != null && r.status != _filterStatus) return false;
      if (_filterUserId != null &&
          _filterUserId!.isNotEmpty &&
          r.userId != _filterUserId) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      final da = _extractDate(a) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = _extractDate(b) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return _sortByDateDesc ? db.compareTo(da) : da.compareTo(db);
    });

    final start = page * pageSize;
    final nextSlice = <Request>[];
    if (start < filtered.length) {
      final end = (start + pageSize).clamp(0, filtered.length);
      nextSlice.addAll(filtered.sublist(start, end));
    }

    setState(() {
      if (replace) {
        _items
          ..clear()
          ..addAll(nextSlice);
      } else {
        _items.addAll(nextSlice);
      }
      _page = page;
      _hasMore = (start + pageSize) < filtered.length;
    });
  }

  Future<void> _onRefresh() async {
    await _loadAllRequests();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    final nextPage = _page + 1;
    // small delay UX
    await Future.delayed(const Duration(milliseconds: 200));
    _applyFiltersAndSetPage(nextPage, replace: false);
    if (mounted) setState(() => _isLoadingMore = false);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >= _scroll_controller_threshold()) {
      _loadMore();
    }
  }

  double _scroll_controller_threshold() {
    return _scrollController.position.maxScrollExtent - 200;
  }

  DateTime? _extractDate(Request r) {
    final raw = r.data['date'] ?? r.data['createdAt'] ?? r.data['timestamp'];
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is int) {
      if (raw.toString().length <= 10) {
        return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      }
      return DateTime.fromMillisecondsSinceEpoch(raw);
    }
    return null;
  }

  void _openFilterSheet() {
    // (mantener implementación previa)
    RequestType? tmpType = _filterType;
    RequestStatus? tmpStatus = _filterStatus;
    String? tmpUserId = _filterUserId;
    bool tmpSortDesc = _sortByDateDesc;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: StatefulBuilder(
            builder: (context, setStateSheet) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Filtros',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setStateSheet(() {
                              tmpType = null;
                              tmpStatus = null;
                              tmpUserId = null;
                              tmpSortDesc = true;
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(
                          width: 8,
                          child: Icon(Icons.category, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<RequestType?>(
                            isExpanded: true,
                            value: tmpType,
                            items: <DropdownMenuItem<RequestType?>>[
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Todos los tipos'),
                              ),
                              ...RequestType.values.map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(_typeLabel(t)),
                                ),
                              ),
                            ],
                            onChanged: (v) => setStateSheet(() => tmpType = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(
                          width: 8,
                          child: Icon(Icons.info_outline, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<RequestStatus?>(
                            isExpanded: true,
                            value: tmpStatus,
                            items: <DropdownMenuItem<RequestStatus?>>[
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Todos los estados'),
                              ),
                              ...RequestStatus.values.map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(_statusLabel(s)),
                                ),
                              ),
                            ],
                            onChanged: (v) =>
                                setStateSheet(() => tmpStatus = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(
                          width: 8,
                          child: Icon(Icons.person_outline, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Filtrar por userId (exacto)',
                              isDense: true,
                            ),
                            controller: TextEditingController(text: tmpUserId),
                            onChanged: (v) =>
                                tmpUserId = v.isEmpty ? null : v.trim(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.sort, size: 18),
                        const SizedBox(width: 12),
                        const Text('Ordenar por fecha:'),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Más recientes'),
                          selected: tmpSortDesc,
                          onSelected: (v) =>
                              setStateSheet(() => tmpSortDesc = true),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Más antiguas'),
                          selected: !tmpSortDesc,
                          onSelected: (v) =>
                              setStateSheet(() => tmpSortDesc = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _filterType = tmpType;
                                _filterStatus = tmpStatus;
                                _filterUserId = tmpUserId;
                                _sortByDateDesc = tmpSortDesc;
                              });
                              Navigator.of(ctx).pop();
                              // reaplicar filtros y resetear paginado
                              _applyFiltersAndSetPage(0, replace: true);
                            },
                            child: const Text('Aplicar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _typeLabel(RequestType t) {
    switch (t) {
      case RequestType.companySuggestion:
        return 'Sugerencia de empresa';
      case RequestType.editRequest:
        return 'Solicitud de edición';
      case RequestType.reportIssue:
        return 'Reporte';
      case RequestType.other:
        return 'Otro';
    }
  }

  String _statusLabel(RequestStatus s) {
    switch (s) {
      case RequestStatus.approved:
        return 'Aprobado';
      case RequestStatus.rejected:
        return 'Rechazado';
      case RequestStatus.pending:
        return 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeFilters = <Widget>[];
    if (_filterType != null) {
      activeFilters.add(Chip(label: Text(_typeLabel(_filterType!))));
    }
    if (_filterStatus != null) {
      activeFilters.add(Chip(label: Text(_statusLabel(_filterStatus!))));
    }
    if (_filterUserId != null && _filterUserId!.isNotEmpty) {
      activeFilters.add(Chip(label: Text('User: ${_filterUserId!}')));
    }

    final content = RefreshIndicator(
      onRefresh: _onRefresh,
      child: Column(
        children: [
          if (activeFilters.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.grey[50],
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: activeFilters
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: c,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          Expanded(
            child: _isRefreshing && _items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount:
                        _items.length + (_isLoadingMore || _hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _items.length) {
                        final req = _items[index];
                        return RequestCard(request: req);
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: _isLoadingMore
                                ? const CircularProgressIndicator()
                                : const SizedBox.shrink(),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );

    return AppScaffold(
      title: 'Solicitudes',
      currentPageIndex: 0,
      scaffoldExtras: {
        'floatingActionButton': FloatingActionButton(
          onPressed: _openFilterSheet,
          tooltip: 'Filtrar / ordenar',
          child: const Icon(Icons.filter_alt),
        ),
      },
      child: content,
    );
  }
}
