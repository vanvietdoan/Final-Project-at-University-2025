import 'package:flutter/material.dart';
import 'package:my_flutter_app_new/screens/plants/plant_detail_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/plant_service.dart';
import '../../models/plant.dart';
import 'dart:async';
import '../../services/division_service.dart';
import '../../models/division.dart';
import '../../services/class_service.dart';
import '../../models/class.dart';
import 'package:flutter/foundation.dart';
import '../../services/order_service.dart';
import '../../models/order.dart';
import '../../services/family_service.dart';
import '../../models/family.dart';
import '../../services/genus_service.dart';
import '../../models/genus.dart';
import '../../services/species_service.dart';
import '../../models/species.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({Key? key}) : super(key: key);

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  final PlantService _plantService = PlantService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Plant> _plants = [];
  List<Plant> _allPlants = [];
  bool _isLoading = false;
  Timer? _searchDebounce;
  int _currentPage = 0;
  static const int _cardsPerPage = 12;

  List<Plant> get _paginatedPlants {
    final startIndex = _currentPage * _cardsPerPage;
    final endIndex = startIndex + _cardsPerPage;
    return _plants.length > startIndex
        ? _plants.sublist(
          startIndex,
          endIndex > _plants.length ? _plants.length : endIndex,
        )
        : [];
  }

  int get _totalPages => (_plants.length / _cardsPerPage).ceil();

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      setState(() => _currentPage = page);
    }
  }

  // Filter states
  final Map<String, String?> _selectedFilters = {
    'division': null,
    'class': null,
    'order': null,
    'family': null,
    'genus': null,
    'species': null,
  };
  bool _isFilterExpanded = false;
  bool _isLoadingFilters = false;

  // Filter data
  final Map<String, List<dynamic>> _filterData = {
    'divisions': [],
    'classes': [],
    'orders': [],
    'families': [],
    'genera': [],
    'species': [],
  };

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _loadFilterData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _filterPlants);
  }

  void _clearSearch() {
    _searchController.clear();
    _filterPlants();
  }

  void _filterPlants() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _plants = List.from(_allPlants);
      } else {
        final searchText = _searchController.text.toLowerCase();
        _plants =
            _allPlants.where((plant) {
              final name = plant.name.toLowerCase();
              final englishName = plant.englishName?.toLowerCase() ?? '';
              return name.contains(searchText) ||
                  englishName.contains(searchText);
            }).toList();
      }
    });
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);

    try {
      final query = _buildFilterQuery();
      final plants =
          query.isEmpty
              ? await _plantService.getPlants()
              : await _plantService.getPlantSearch(query);

      setState(() {
        _allPlants = plants;
        _plants = List.from(_allPlants);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách cây: $e')),
        );
      }
    }
  }

  String _buildFilterQuery() {
    final filters = _selectedFilters.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}Id=${entry.value}')
        .join('&');
    return filters;
  }

  Future<void> _onRefresh() async {
    await _loadPlants();
  }

  Future<void> _loadFilterData() async {
    if (_isLoadingFilters) return;

    setState(() => _isLoadingFilters = true);

    try {
      final divisions = await DivisionService().getDivisions();
      final classes = await ClassService().getClasses();
      final orders = await OrderService().getOrders();
      final families = await FamilyService().getFamilies();

      if (kDebugMode) {
        debugPrint('Loaded divisions: ${divisions.length} items');
        debugPrint('Loaded classes: ${classes.length} items');
        debugPrint('Loaded orders: ${orders.length} items');
        debugPrint('Loaded families: ${families.length} items');
      }

      setState(() {
        _filterData['divisions'] = divisions;
        _filterData['classes'] = classes;
        _filterData['orders'] = orders;
        _filterData['families'] = families;
        _isLoadingFilters = false;
      });
    } catch (e) {
      setState(() => _isLoadingFilters = false);
      if (mounted) {
        String errorMessage = 'Không thể kết nối đến máy chủ';
        if (e.toString().contains('SocketException')) {
          errorMessage =
              'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet của bạn.';
        } else if (e.toString().contains('timeout')) {
          errorMessage =
              'Kết nối đến máy chủ bị timeout. Vui lòng thử lại sau.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: _loadFilterData,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadGeneraByFamily(int familyId) async {
    try {
      final genera = await GenusService().getGenuses();
      setState(() {
        _filterData['genera'] =
            genera.where((genus) => genus.familyId == familyId).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách chi: $e')),
        );
      }
    }
  }

  Future<void> _loadSpeciesByGenus(int genusId) async {
    try {
      final species = await SpeciesService().getSpecies();
      setState(() {
        _filterData['species'] =
            species.where((s) => s.genusId == genusId).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách loài: $e')),
        );
      }
    }
  }

  void _handleFilterChange(String filterType, String? value) {
    setState(() {
      _selectedFilters[filterType] = value;

      // Reset dependent filters
      switch (filterType) {
        case 'division':
          _selectedFilters['class'] = null;
          _selectedFilters['order'] = null;
          _selectedFilters['family'] = null;
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          break;
        case 'class':
          _selectedFilters['order'] = null;
          _selectedFilters['family'] = null;
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          break;
        case 'order':
          _selectedFilters['family'] = null;
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          break;
        case 'family':
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          _filterData['genera'] = [];
          if (value != null) {
            _loadGeneraByFamily(int.parse(value));
          }
          break;
        case 'genus':
          _selectedFilters['species'] = null;
          _filterData['species'] = [];
          if (value != null) {
            _loadSpeciesByGenus(int.parse(value));
          }
          break;
      }
    });
    _loadPlants();
  }

  void _clearFilter(String filterType) {
    setState(() {
      _selectedFilters[filterType] = null;
      // Clear dependent filters
      switch (filterType) {
        case 'division':
          _selectedFilters['class'] = null;
          _selectedFilters['order'] = null;
          _selectedFilters['family'] = null;
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          break;
        case 'class':
          _selectedFilters['order'] = null;
          _selectedFilters['family'] = null;
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          break;
        case 'order':
          _selectedFilters['family'] = null;
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          break;
        case 'family':
          _selectedFilters['genus'] = null;
          _selectedFilters['species'] = null;
          _filterData['genera'] = [];
          break;
        case 'genus':
          _selectedFilters['species'] = null;
          _filterData['species'] = [];
          break;
      }
    });
    _loadPlants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchAndFilterCard(
              searchController: _searchController,
              isFilterExpanded: _isFilterExpanded,
              onFilterToggle:
                  () => setState(() => _isFilterExpanded = !_isFilterExpanded),
              onClearSearch: _clearSearch,
              filterContent:
                  _isFilterExpanded
                      ? FilterContent(
                        filterData: _filterData,
                        selectedFilters: _selectedFilters,
                        isLoadingFilters: _isLoadingFilters,
                        onFilterChange: _handleFilterChange,
                        onClearFilter: _clearFilter,
                      )
                      : null,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: PlantsGrid(
                  plants: _paginatedPlants,
                  isLoading: _isLoading,
                  searchText: _searchController.text,
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onPageChanged: _goToPage,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}

class SearchAndFilterCard extends StatelessWidget {
  final TextEditingController searchController;
  final bool isFilterExpanded;
  final VoidCallback onFilterToggle;
  final VoidCallback onClearSearch;
  final Widget? filterContent;

  const SearchAndFilterCard({
    super.key,
    required this.searchController,
    required this.isFilterExpanded,
    required this.onFilterToggle,
    required this.onClearSearch,
    this.filterContent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm cây thuốc....',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: onClearSearch,
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isFilterExpanded
                        ? Icons.filter_list_off
                        : Icons.filter_list,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: onFilterToggle,
                  tooltip: isFilterExpanded ? 'Ẩn bộ lọc' : 'Hiện bộ lọc',
                ),
              ],
            ),
          ),
          if (isFilterExpanded) ...[
            const Divider(height: 1),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: filterContent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FilterContent extends StatelessWidget {
  final Map<String, List<dynamic>> filterData;
  final Map<String, String?> selectedFilters;
  final bool isLoadingFilters;
  final Function(String, String?) onFilterChange;
  final Function(String) onClearFilter;

  const FilterContent({
    super.key,
    required this.filterData,
    required this.selectedFilters,
    required this.isLoadingFilters,
    required this.onFilterChange,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: Ngành, Lớp, Bộ
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFilterDropdown(
                'division',
                'Ngành',
                filterData['divisions'] ?? [],
                selectedFilters['division'],
              ),
            ),
            const SizedBox(width: 16),
            if (selectedFilters['division'] != null)
              Expanded(
                child: _buildFilterDropdown(
                  'class',
                  'Lớp',
                  filterData['classes'] ?? [],
                  selectedFilters['class'],
                  parentValue: selectedFilters['division'],
                  parentField: 'division_id',
                ),
              )
            else
              const Expanded(child: SizedBox()),
            const SizedBox(width: 16),
            if (selectedFilters['class'] != null)
              Expanded(
                child: _buildFilterDropdown(
                  'order',
                  'Bộ',
                  filterData['orders'] ?? [],
                  selectedFilters['order'],
                  parentValue: selectedFilters['class'],
                  parentField: 'class_id',
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),

        // Row 2: Họ, Chi, Loài
        if (selectedFilters['order'] != null) ...[
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'family',
                  'Họ',
                  filterData['families'] ?? [],
                  selectedFilters['family'],
                  parentValue: selectedFilters['order'],
                  parentField: 'order_id',
                ),
              ),
              const SizedBox(width: 16),
              if (selectedFilters['family'] != null)
                Expanded(
                  child: _buildFilterDropdown(
                    'genus',
                    'Chi',
                    filterData['genera'] ?? [],
                    selectedFilters['genus'],
                    parentValue: selectedFilters['family'],
                    parentField: 'family_id',
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              const SizedBox(width: 16),
              if (selectedFilters['genus'] != null)
                Expanded(
                  child: _buildFilterDropdown(
                    'species',
                    'Loài',
                    filterData['species'] ?? [],
                    selectedFilters['species'],
                    parentValue: selectedFilters['genus'],
                    parentField: 'genus_id',
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFilterDropdown(
    String filterType,
    String label,
    List<dynamic> items,
    String? selectedValue, {
    String? parentValue,
    String? parentField,
  }) {
    if (items.isEmpty || (parentValue != null && parentValue.isEmpty)) {
      return const SizedBox();
    }

    List<dynamic> filteredItems = items;
    if (parentValue != null && parentField != null) {
      filteredItems =
          items.where((item) {
            try {
              final itemMap = item.toJson();
              final fieldValue = itemMap[parentField]?.toString();
              return fieldValue != null && fieldValue == parentValue;
            } catch (e) {
              debugPrint('Error filtering $filterType items: $e');
              return false;
            }
          }).toList();
    }

    if (filteredItems.isEmpty) {
      return const SizedBox();
    }

    // Create unique items list
    final uniqueItems =
        filteredItems
            .map((item) {
              try {
                final itemMap = item.toJson();
                String? value;
                String? name;

                // Handle different field names based on filter type
                switch (filterType) {
                  case 'division':
                    value = itemMap['division_id']?.toString();
                    name = itemMap['name']?.toString();
                    break;
                  case 'class':
                    value = itemMap['class_id']?.toString();
                    name = itemMap['name']?.toString();
                    break;
                  case 'order':
                    value = itemMap['order_id']?.toString();
                    name = itemMap['name']?.toString();
                    break;
                  case 'family':
                    value = itemMap['family_id']?.toString();
                    name = itemMap['name']?.toString();
                    break;
                  case 'genus':
                    value = itemMap['genus_id']?.toString();
                    name = itemMap['name']?.toString();
                    break;
                  case 'species':
                    value = itemMap['species_id']?.toString();
                    name = itemMap['name']?.toString();
                    break;
                }

                if (value != null && name != null) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(name),
                  );
                }
                return null;
              } catch (e) {
                debugPrint('Error processing item in $filterType dropdown: $e');
                return null;
              }
            })
            .whereType<DropdownMenuItem<String>>()
            .toList();

    // Remove duplicates based on value
    final uniqueValues = <String>{};
    final finalItems =
        uniqueItems.where((item) {
          if (item.value != null && uniqueValues.add(item.value!)) {
            return true;
          }
          return false;
        }).toList();

    if (finalItems.isEmpty) {
      return const SizedBox();
    }

    // Debug print
    debugPrint('$filterType dropdown items: ${finalItems.length}');
    debugPrint('Selected value: $selectedValue');
    debugPrint(
      'Available values: ${finalItems.map((e) => e.value).join(', ')}',
    );

    return FilterDropdown(
      label: label,
      value: selectedValue,
      items: finalItems,
      onChanged: (value) => onFilterChange(filterType, value),
      onClear: () => onClearFilter(filterType),
      isLoading: isLoadingFilters,
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final Function(String?) onChanged;
  final VoidCallback onClear;
  final bool isLoading;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.onClear,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // Validate value against items
    final validValue = items.any((item) => item.value == value) ? value : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
                if (validValue != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onClear,
                    tooltip: 'Xóa lọc $label',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                  value: validValue,
                  isExpanded: true,
                  hint: Text(
                    'Chọn $label',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  items: items,
                  onChanged: isLoading ? null : onChanged,
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                  icon:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.arrow_drop_down),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlantsGrid extends StatelessWidget {
  final List<Plant> plants;
  final bool isLoading;
  final String searchText;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PlantsGrid({
    super.key,
    required this.plants,
    required this.isLoading,
    required this.searchText,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh sách cây thuốc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (searchText.isNotEmpty)
                Text(
                  'Kết quả tìm kiếm: "$searchText"',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          plants.isEmpty && !isLoading
              ? const EmptyState()
              : Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      return PlantCard(plant: plants[index]);
                    },
                  ),
                  if (totalPages > 1) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed:
                              currentPage > 0
                                  ? () => onPageChanged(currentPage - 1)
                                  : null,
                          icon: const Icon(Icons.chevron_left),
                          color: currentPage > 0 ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        ...List.generate(
                          totalPages,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: TextButton(
                              onPressed: () => onPageChanged(index),
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    currentPage == index
                                        ? Colors.green
                                        : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color:
                                      currentPage == index
                                          ? Colors.white
                                          : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed:
                              currentPage < totalPages - 1
                                  ? () => onPageChanged(currentPage + 1)
                                  : null,
                          icon: const Icon(Icons.chevron_right),
                          color:
                              currentPage < totalPages - 1
                                  ? Colors.green
                                  : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy cây thuốc nào',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({super.key, required this.plant});

  String _ensureHttps(String url) {
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlantDetailScreen(plantId: plant.plantId),
            ),
          );
        },
        child: SizedBox(
          height: 200,
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child:
                    plant.images != null && plant.images!.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: _ensureHttps(plant.images![0].url),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget: (context, url, error) {
                            debugPrint('Error loading plant image: $error');
                            return Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                        : Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      plant.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
