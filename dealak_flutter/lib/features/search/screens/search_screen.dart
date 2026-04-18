import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/data/models/search_filter_model.dart';
import 'package:dealak_flutter/providers/search_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';
import 'package:dealak_flutter/shared/widgets/error_widget.dart';
import 'package:dealak_flutter/shared/widgets/cached_image.dart';
import 'package:dealak_flutter/shared/widgets/empty_state_widget.dart';
import 'package:dealak_flutter/core/utils/debouncer.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 400));
  bool _isGridView = true;

  String _propertyType = '';
  String _listingType = '';
  String _city = '';
  double _minPrice = 0;
  double _maxPrice = 100000000;
  double _minArea = 0;
  double _maxArea = 1000;
  int _bedrooms = 0;
  int _bathrooms = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      ref.read(searchFilterProvider.notifier).state = SearchFilterModel(
        query: query.isEmpty ? null : query,
        propertyType: _propertyType.isEmpty ? null : _propertyType,
        listingType: _listingType.isEmpty ? null : _listingType,
        city: _city.isEmpty ? null : _city,
        minPrice: _minPrice > 0 ? _minPrice : null,
        maxPrice: _maxPrice < 100000000 ? _maxPrice : null,
        minArea: _minArea > 0 ? _minArea : null,
        maxArea: _maxArea < 1000 ? _maxArea : null,
        bedrooms: _bedrooms > 0 ? _bedrooms : null,
        bathrooms: _bathrooms > 0 ? _bathrooms : null,
      );
    });
  }

  void _applyFilters() {
    ref.read(searchFilterProvider.notifier).state = SearchFilterModel(
      query: _searchController.text.isEmpty ? null : _searchController.text,
      propertyType: _propertyType.isEmpty ? null : _propertyType,
      listingType: _listingType.isEmpty ? null : _listingType,
      city: _city.isEmpty ? null : _city,
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < 100000000 ? _maxPrice : null,
      minArea: _minArea > 0 ? _minArea : null,
      maxArea: _maxArea < 1000 ? _maxArea : null,
      bedrooms: _bedrooms > 0 ? _bedrooms : null,
      bathrooms: _bathrooms > 0 ? _bathrooms : null,
    );
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _propertyType = '';
      _listingType = '';
      _city = '';
      _minPrice = 0;
      _maxPrice = 100000000;
      _minArea = 0;
      _maxArea = 1000;
      _bedrooms = 0;
      _bathrooms = 0;
    });
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_propertyType.isNotEmpty) count++;
    if (_listingType.isNotEmpty) count++;
    if (_city.isNotEmpty) count++;
    if (_minPrice > 0 || _maxPrice < 100000000) count++;
    if (_minArea > 0 || _maxArea < 1000) count++;
    if (_bedrooms > 0) count++;
    if (_bathrooms > 0) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ابحث عن عقار...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () => _showFilterBottomSheet(context, isDark),
                    ),
                    if (_getActiveFilterCount() > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '${_getActiveFilterCount()}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: resultsAsync.when(
              data: (paginated) {
                final results = paginated.data;
                if (results.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.search_off,
                    message: 'لا توجد نتائج مطابقة\nجرّب تعديل معايير البحث',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(searchResultsProvider),
                  child: _isGridView
                      ? _buildGridView(results, isDark)
                      : _buildListView(results, isDark),
                );
              },
              loading: () => const LoadingWidget(message: 'جاري البحث...'),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(searchResultsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<PropertyModel> results, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) => _PropertyGridItem(property: results[index], isDark: isDark),
    );
  }

  Widget _buildListView(List<PropertyModel> results, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) => _PropertyListItem(property: results[index], isDark: isDark),
    );
  }

  void _showFilterBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الفلاتر', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(onPressed: _clearFilters, child: const Text('مسح الكل')),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('نوع العقار', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip('شقة', 'APARTMENT', isDark),
                        _buildFilterChip('منزل', 'HOUSE', isDark),
                        _buildFilterChip('فيلا', 'VILLA', isDark),
                        _buildFilterChip('أرض', 'LAND', isDark),
                        _buildFilterChip('تجاري', 'COMMERCIAL', isDark),
                        _buildFilterChip('مكتب', 'OFFICE', isDark),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('نوع الإدراج', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip('بيع', 'SALE', isDark),
                        _buildFilterChip('إيجار شهري', 'RENT_MONTHLY', isDark),
                        _buildFilterChip('إيجار سنوي', 'RENT_YEARLY', isDark),
                        _buildFilterChip('إيجار يومي', 'RENT_DAILY', isDark),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('السعر (ل.س)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'الأقل',
                              filled: true,
                              fillColor: isDark ? AppColors.cardDark : Colors.grey[50],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (v) => setState(() => _minPrice = double.tryParse(v) ?? 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'الأعلى',
                              filled: true,
                              fillColor: isDark ? AppColors.cardDark : Colors.grey[50],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (v) => setState(() => _maxPrice = double.tryParse(v) ?? 100000000),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('المساحة (م²)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'الأقل',
                              filled: true,
                              fillColor: isDark ? AppColors.cardDark : Colors.grey[50],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (v) => setState(() => _minArea = double.tryParse(v) ?? 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'الأعلى',
                              filled: true,
                              fillColor: isDark ? AppColors.cardDark : Colors.grey[50],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (v) => setState(() => _maxArea = double.tryParse(v) ?? 1000),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('الغرف', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildCounterButton(Icons.remove, () => setState(() => _bedrooms = (_bedrooms - 1).clamp(0, 10)), isDark),
                        Container(
                          width: 60,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$_bedrooms', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        _buildCounterButton(Icons.add, () => setState(() => _bedrooms = (_bedrooms + 1).clamp(0, 10)), isDark),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('الحمامات', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildCounterButton(Icons.remove, () => setState(() => _bathrooms = (_bathrooms - 1).clamp(0, 10)), isDark),
                        Container(
                          width: 60,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$_bathrooms', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        _buildCounterButton(Icons.add, () => setState(() => _bathrooms = (_bathrooms + 1).clamp(0, 10)), isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('تطبيق الفلاتر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = (_propertyType == value) || (_listingType == value);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (['APARTMENT', 'HOUSE', 'VILLA', 'LAND', 'COMMERCIAL', 'OFFICE'].contains(value)) {
            _propertyType = selected ? value : '';
          } else {
            _listingType = selected ? value : '';
          }
        });
      },
      backgroundColor: isDark ? AppColors.cardDark : Colors.grey[100],
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black)),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed, bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(icon: Icon(icon), onPressed: onPressed),
    );
  }
}

class _PropertyGridItem extends StatelessWidget {
  final PropertyModel property;
  final bool isDark;
  const _PropertyGridItem({required this.property, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.propertyDetail}/${property.id}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? AppColors.cardDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: property.images.isNotEmpty
                        ? CachedImage(imageUrl: property.images.first.imageUrl, width: double.infinity, fit: BoxFit.cover)
                        : Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
                  ),
                  if (property.isFeatured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('مميز', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Formatters.currency(property.price), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(property.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${property.city}${property.district != null ? ' - ${property.district}' : ''}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  if (property.bedrooms != null || property.bathrooms != null || property.areaSqm != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          if (property.bedrooms != null) ...[
                            const Icon(Icons.bed, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${property.bedrooms}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                          if (property.bathrooms != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.bathtub, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${property.bathrooms}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                          if (property.areaSqm != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.square_foot, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${property.areaSqm} م²', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyListItem extends StatelessWidget {
  final PropertyModel property;
  final bool isDark;
  const _PropertyListItem({required this.property, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.propertyDetail}/${property.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? AppColors.cardDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    property.images.isNotEmpty
                        ? CachedImage(imageUrl: property.images.first.imageUrl, width: 100, height: 100, fit: BoxFit.cover)
                        : Container(width: 100, height: 100, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
                    if (property.isFeatured)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(4)),
                          child: const Text('مميز', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Formatters.currency(property.price), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text(property.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('${property.city}${property.district != null ? ' - ${property.district}' : ''}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    if (property.bedrooms != null || property.bathrooms != null || property.areaSqm != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            if (property.bedrooms != null) ...[
                              const Icon(Icons.bed, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('${property.bedrooms}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                            if (property.bathrooms != null) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.bathtub, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('${property.bathrooms}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                            if (property.areaSqm != null) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.square_foot, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text('${property.areaSqm} م²', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
