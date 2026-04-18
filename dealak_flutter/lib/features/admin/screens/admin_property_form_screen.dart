import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/router/route_names.dart';
import 'package:dealak_flutter/core/utils/formatters.dart';
import 'package:dealak_flutter/data/models/property_model.dart';
import 'package:dealak_flutter/providers/admin_provider.dart';
import 'package:dealak_flutter/shared/widgets/loading_widget.dart';

class AdminPropertyFormScreen extends ConsumerStatefulWidget {
  final int? propertyId;
  const AdminPropertyFormScreen({super.key, this.propertyId});

  @override
  ConsumerState<AdminPropertyFormScreen> createState() => _AdminPropertyFormScreenState();
}

class _AdminPropertyFormScreenState extends ConsumerState<AdminPropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();

  String _propertyType = 'APARTMENT';
  String _listingType = 'SALE';
  String _status = 'AVAILABLE';
  bool _isFeatured = false;
  bool _isNegotiable = true;
  int _bedrooms = 0;
  int _bathrooms = 0;
  int _floors = 0;
  int _yearBuilt = 0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.propertyId != null) {
      _loadProperty();
    }
  }

  Future<void> _loadProperty() async {
    setState(() => _isLoading = true);
    try {
      final params = <String, dynamic>{'page': 1, 'per_page': 100};
      final result = await ref.read(adminPropertiesProvider(params).future);
      final property = result.data.firstWhere((p) => p.id == widget.propertyId);
      if (mounted) {
        setState(() {
          _titleController.text = property.title;
          _descriptionController.text = property.description ?? '';
          _priceController.text = property.price.toString();
          _areaController.text = property.areaSqm?.toString() ?? '';
          _addressController.text = property.address ?? '';
          _cityController.text = property.city;
          _districtController.text = property.district ?? '';
          _propertyType = property.propertyType;
          _listingType = property.listingType;
          _status = property.status;
          _isFeatured = property.isFeatured;
          _isNegotiable = property.isNegotiable;
          _bedrooms = property.bedrooms ?? 0;
          _bathrooms = property.bathrooms ?? 0;
          _floors = property.floors ?? 0;
          _yearBuilt = property.yearBuilt ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'property_type': _propertyType,
        'listing_type': _listingType,
        'status': _status,
        'price': double.parse(_priceController.text),
        'area_sqm': _areaController.text.isNotEmpty ? double.parse(_areaController.text) : null,
        'address': _addressController.text,
        'city': _cityController.text,
        'district': _districtController.text,
        'bedrooms': _bedrooms > 0 ? _bedrooms : null,
        'bathrooms': _bathrooms > 0 ? _bathrooms : null,
        'floors': _floors > 0 ? _floors : null,
        'year_built': _yearBuilt > 0 ? _yearBuilt : null,
        'is_featured': _isFeatured,
        'is_negotiable': _isNegotiable,
      };

      if (widget.propertyId != null) {
        await ref.read(adminPropertyProvider.notifier).updateProperty(widget.propertyId!, data);
      } else {
        await ref.read(adminPropertyProvider.notifier).createProperty(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.propertyId != null ? 'تم تحديث العقار' : 'تم إضافة العقار')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(appBar: AppBar(title: const Text('جاري التحميل...')), body: const LoadingWidget());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.propertyId != null ? 'تعديل عقار' : 'إضافة عقار جديد'),
        actions: [
          if (widget.propertyId != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('تأكيد الحذف'),
                    content: const Text('هل أنت متأكد من حذف هذا العقار؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(adminPropertyProvider.notifier).deleteProperty(widget.propertyId!);
                  if (mounted) {
                    context.pop();
                  }
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'عنوان العقار *', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _propertyType,
              decoration: const InputDecoration(labelText: 'نوع العقار *', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'APARTMENT', child: Text('شقة')),
                DropdownMenuItem(value: 'HOUSE', child: Text('منزل')),
                DropdownMenuItem(value: 'VILLA', child: Text('فيلا')),
                DropdownMenuItem(value: 'LAND', child: Text('أرض')),
                DropdownMenuItem(value: 'COMMERCIAL', child: Text('تجاري')),
                DropdownMenuItem(value: 'OFFICE', child: Text('مكتب')),
              ],
              onChanged: (v) => setState(() => _propertyType = v!),
              validator: (v) => v == null ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _listingType,
              decoration: const InputDecoration(labelText: 'نوع الإدراج *', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'SALE', child: Text('بيع')),
                DropdownMenuItem(value: 'RENT_MONTHLY', child: Text('إيجار شهري')),
                DropdownMenuItem(value: 'RENT_YEARLY', child: Text('إيجار سنوي')),
                DropdownMenuItem(value: 'RENT_DAILY', child: Text('إيجار يومي')),
              ],
              onChanged: (v) => setState(() => _listingType = v!),
              validator: (v) => v == null ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'الحالة *', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'AVAILABLE', child: Text('متاح')),
                DropdownMenuItem(value: 'SOLD', child: Text('مباع')),
                DropdownMenuItem(value: 'RENTED', child: Text('مؤجر')),
                DropdownMenuItem(value: 'PENDING', child: Text('قيد المراجعة')),
                DropdownMenuItem(value: 'RESERVED', child: Text('محجوز')),
              ],
              onChanged: (v) => setState(() => _status = v!),
              validator: (v) => v == null ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'السعر (ل.س) *', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المساحة (م²)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'المدينة *', border: OutlineInputBorder()),
              validator: (v) => v?.isEmpty ?? true ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(labelText: 'الحي', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الغرف', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() => _bedrooms = int.tryParse(v) ?? 0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الحمامات', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() => _bathrooms = int.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'الطوابق', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() => _floors = int.tryParse(v) ?? 0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'سنة البناء', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() => _yearBuilt = int.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('عقار مميز'),
              value: _isFeatured,
              onChanged: (v) => setState(() => _isFeatured = v),
            ),
            SwitchListTile(
              title: const Text('قابل للتفاوض'),
              value: _isNegotiable,
              onChanged: (v) => setState(() => _isNegotiable = v),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('إضافة صور'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),
            const SizedBox(height: 16),
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    final image = _selectedImages[index];
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(image.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImages.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading ? const LoadingWidget() : Text(widget.propertyId != null ? 'تحديث' : 'إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}
