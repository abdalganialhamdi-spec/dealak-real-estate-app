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
  bool _showFilters = false;

  String _propertyType = '';
  String _listingType = '';
  String _city = '';
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _minAreaController = TextEditingController();
  final _maxAreaController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minAreaController.dispose();
    _maxAreaController.dispose();
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
        minPrice: double.tryParse(_minPriceController.text),
        maxPrice: double.tryParse(_maxPriceController.text),
        minArea: double.tryParse(_minAreaController.text),
        maxArea: double.tryParse(_maxAreaController.text),
      );
    });
  }

  void _applyFilters() {
    ref.read(searchFilterProvider.notifier).state = SearchFilterModel(
      query: _searchController.text.isEmpty ? null : _searchController.text,
      propertyType: _propertyType.isEmpty ? null : _propertyType,
      listingType: _listingType.isEmpty ? null : _listingType,
      city: _city.isEmpty ? null : _city,
      minPrice: double.tryParse(_minPriceController.text),
      maxPrice: double.tryParse(_maxPriceController.text),
      minArea: double.tryParse(_minAreaController.text),
      maxArea: double.tryParse(_maxAreaController.text),
    );
    setState(() => _showFilters = false);
  }

  void _clearFilters() {
    setState(() {
      _propertyType = '';
      _listingType = '';
      _city = '';
      _minPriceController.clear();
      _maxPriceController.clear();
      _minAreaController.clear();
      _maxAreaController.clear();
    });
    ref.read(searchFilterProvider.notifier).state = SearchFilterModel();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('البحث')),
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
                suffixIcon: IconButton(
                  icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_outlined),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                ),
              ),
            ),
          ),
          if (_showFilters) _buildFilterPanel(),
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
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: results.length,
                    itemBuilder: (context, index) => _SearchResultItem(property: results[index]),
                  ),
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

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الفلاتر', style: Theme.of(context).textTheme.titleMedium),
              TextButton(onPressed: _clearFilters, child: const Text('مسح الكل')),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _propertyType.isEmpty ? null : _propertyType,
            decoration: const InputDecoration(labelText: 'نوع العقار', isDense: true),
            items: const [
              DropdownMenuItem(value: 'APARTMENT', child: Text('شقة')),
              DropdownMenuItem(value: 'HOUSE', child: Text('منزل')),
              DropdownMenuItem(value: 'VILLA', child: Text('فيلا')),
              DropdownMenuItem(value: 'LAND', child: Text('أرض')),
              DropdownMenuItem(value: 'COMMERCIAL', child: Text('تجاري')),
              DropdownMenuItem(value: 'OFFICE', child: Text('مكتب')),
            ],
            onChanged: (v) => setState(() => _propertyType = v ?? ''),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _listingType.isEmpty ? null : _listingType,
            decoration: const InputDecoration(labelText: 'نوع الإدراج', isDense: true),
            items: const [
              DropdownMenuItem(value: 'SALE', child: Text('بيع')),
              DropdownMenuItem(value: 'RENT_MONTHLY', child: Text('إيجار شهري')),
              DropdownMenuItem(value: 'RENT_YEARLY', child: Text('إيجار سنوي')),
              DropdownMenuItem(value: 'RENT_DAILY', child: Text('إيجار يومي')),
            ],
            onChanged: (v) => setState(() => _listingType = v ?? ''),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'أقل سعر', isDense: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'أعلى سعر', isDense: true),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _applyFilters, child: const Text('تطبيق الفلاتر')),
          ),
        ],
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final PropertyModel property;
  const _SearchResultItem({required this.property});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${RouteNames.propertyDetail}/${property.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
              child: property.images.isNotEmpty
                  ? CachedImage(imageUrl: property.images.first.imageUrl, width: 100, height: 100, fit: BoxFit.cover)
                  : Container(width: 100, height: 100, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Formatters.currency(property.price), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    const SizedBox(height: 2),
                    Text(property.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('${property.city}${property.district != null ? ' - ${property.district}' : ''}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
