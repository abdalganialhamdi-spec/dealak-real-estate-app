import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/utils/validators.dart';
import 'package:dealak_flutter/shared/widgets/custom_button.dart';
import 'package:dealak_flutter/shared/widgets/custom_text_field.dart';
import 'package:dealak_flutter/providers/property_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dealak_flutter/core/network/api_exceptions.dart';
import 'package:dio/dio.dart' show MultipartFile;

class PropertyCreateScreen extends ConsumerStatefulWidget {
  const PropertyCreateScreen({super.key});

  @override
  ConsumerState<PropertyCreateScreen> createState() =>
      _PropertyCreateScreenState();
}

class _PropertyCreateScreenState extends ConsumerState<PropertyCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _yearBuiltController = TextEditingController();

  String _propertyType = 'APARTMENT';
  String _listingType = 'SALE';
  String _currency = 'SYP';
  bool _isNegotiable = true;
  bool _isLoading = false;
  final List<XFile> _selectedImages = [];
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _yearBuiltController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _fieldErrors = {};
    });
    try {
      final repo = ref.read(propertyRepositoryProvider);
      
      final files = await Future.wait(
        _selectedImages.map(
          (xfile) => MultipartFile.fromFile(xfile.path, filename: xfile.name),
        ),
      );

      await repo.createPropertyWithImages(
        data: {
          'title': _titleController.text,
          'description': _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          'property_type': _propertyType,
          'listing_type': _listingType,
          'price': double.tryParse(_priceController.text) ?? 0,
          'currency': _currency,
          'area_sqm': double.tryParse(_areaController.text),
          'bedrooms': int.tryParse(_bedroomsController.text),
          'bathrooms': int.tryParse(_bathroomsController.text),
          'year_built': int.tryParse(_yearBuiltController.text),
          'address': _addressController.text.isEmpty
              ? null
              : _addressController.text,
          'city': _cityController.text,
          'district': _districtController.text.isEmpty
              ? null
              : _districtController.text,
          'is_negotiable': _isNegotiable,
        },
        images: files,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم إضافة العقار بنجاح')));
        context.pop();
      }
    } on ValidationException catch (e) {
      setState(() {
        _fieldErrors = e.errors?.map((key, value) {
          if (value is List) {
            return MapEntry(key, value.join('\n'));
          }
          return MapEntry(key, value.toString());
        }) ?? {};
      });
    } catch (e) {
      if (mounted) {
        String message = e.toString();
        if (message.contains('images')) {
          message = 'تم إنشاء العقار ولكن فشل رفع الصور. يمكنك تعديل العقار لاحقاً لرفع الصور.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 5)));
        
        // If it was just an image upload failure, maybe we still want to pop or stay?
        // If the property was created, it's better to stay and show a specific retry or just go to my properties.
        if (message.contains('رفع الصور')) {
            context.pop();
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عقار')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'عنوان العقار',
                controller: _titleController,
                validator: (v) => Validators.required(v, 'عنوان العقار'),
                errorText: _fieldErrors['title'],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'الوصف',
                controller: _descriptionController,
                maxLines: 4,
                errorText: _fieldErrors['description'],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _propertyType,
                decoration: InputDecoration(
                  labelText: 'نوع العقار',
                  prefixIcon: const Icon(Icons.home_work_outlined),
                  errorText: _fieldErrors['property_type'],
                ),
                items: const [
                  DropdownMenuItem(value: 'APARTMENT', child: Text('شقة')),
                  DropdownMenuItem(value: 'HOUSE', child: Text('منزل')),
                  DropdownMenuItem(value: 'VILLA', child: Text('فيلا')),
                  DropdownMenuItem(value: 'LAND', child: Text('أرض')),
                  DropdownMenuItem(value: 'COMMERCIAL', child: Text('تجاري')),
                  DropdownMenuItem(value: 'OFFICE', child: Text('مكتب')),
                  DropdownMenuItem(value: 'WAREHOUSE', child: Text('مستودع')),
                  DropdownMenuItem(value: 'FARM', child: Text('مزرعة')),
                ],
                onChanged: (v) => setState(() => _propertyType = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _listingType,
                decoration: InputDecoration(
                  labelText: 'نوع الإدراج',
                  prefixIcon: const Icon(Icons.list),
                  errorText: _fieldErrors['listing_type'],
                ),
                items: const [
                  DropdownMenuItem(value: 'SALE', child: Text('بيع')),
                  DropdownMenuItem(
                    value: 'RENT_MONTHLY',
                    child: Text('إيجار شهري'),
                  ),
                  DropdownMenuItem(
                    value: 'RENT_YEARLY',
                    child: Text('إيجار سنوي'),
                  ),
                  DropdownMenuItem(
                    value: 'RENT_DAILY',
                    child: Text('إيجار يومي'),
                  ),
                ],
                onChanged: (v) => setState(() => _listingType = v!),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      label: 'السعر',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.required(v, 'السعر'),
                      errorText: _fieldErrors['price'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: InputDecoration(
                        labelText: 'العملة',
                        errorText: _fieldErrors['currency'],
                      ),
                      items: const [
                        DropdownMenuItem(value: 'SYP', child: Text('ل.س')),
                        DropdownMenuItem(value: 'USD', child: Text('\$')),
                        DropdownMenuItem(value: 'EUR', child: Text('€')),
                      ],
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('قابل للتفاوض'),
                value: _isNegotiable,
                onChanged: (v) => setState(() => _isNegotiable = v),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'المساحة (م²)',
                      controller: _areaController,
                      keyboardType: TextInputType.number,
                      errorText: _fieldErrors['area_sqm'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'غرف النوم',
                      controller: _bedroomsController,
                      keyboardType: TextInputType.number,
                      errorText: _fieldErrors['bedrooms'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'الحمامات',
                      controller: _bathroomsController,
                      keyboardType: TextInputType.number,
                      errorText: _fieldErrors['bathrooms'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'سنة البناء',
                controller: _yearBuiltController,
                keyboardType: TextInputType.number,
                errorText: _fieldErrors['year_built'],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'المدينة',
                controller: _cityController,
                validator: (v) => Validators.required(v, 'المدينة'),
                prefixIcon: const Icon(Icons.location_city),
                errorText: _fieldErrors['city'],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'الحي/المنطقة',
                controller: _districtController,
                errorText: _fieldErrors['district'],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'العنوان التفصيلي',
                controller: _addressController,
                errorText: _fieldErrors['address'],
              ),
              const SizedBox(height: 24),
              Text('صور العقار', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _buildImagePicker(),
              const SizedBox(height: 32),
              CustomButton(
                label: 'إضافة العقار',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._selectedImages.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(image.path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.divider,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, color: AppColors.textSecondary),
                SizedBox(height: 4),
                Text(
                  'إضافة صورة',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
