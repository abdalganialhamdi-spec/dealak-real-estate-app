import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dealak_flutter/core/constants/app_colors.dart';
import 'package:dealak_flutter/core/utils/validators.dart';
import 'package:dealak_flutter/shared/widgets/custom_button.dart';
import 'package:dealak_flutter/shared/widgets/custom_text_field.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  String _propertyType = 'APARTMENT';
  String _listingType = 'SALE';
  String? _city;
  final List<String> _cities = ['دمشق', 'حلب', 'حمص', 'حماة', 'اللاذقية', 'طرطوس', 'دير الزور', 'الرقة', 'إدلب', 'درعا', 'السويداء', 'القنيطرة'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء طلب عقاري')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'عنوان الطلب',
                controller: _titleController,
                validator: (v) => Validators.required(v, 'عنوان الطلب'),
                prefixIcon: const Icon(Icons.title),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'وصف الطلب',
                controller: _descriptionController,
                maxLines: 4,
                validator: (v) => Validators.required(v, 'وصف الطلب'),
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _propertyType,
                decoration: InputDecoration(
                  labelText: 'نوع العقار',
                  prefixIcon: const Icon(Icons.home_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'APARTMENT', child: Text('شقة')),
                  DropdownMenuItem(value: 'HOUSE', child: Text('منزل')),
                  DropdownMenuItem(value: 'VILLA', child: Text('فيلا')),
                  DropdownMenuItem(value: 'LAND', child: Text('أرض')),
                  DropdownMenuItem(value: 'COMMERCIAL', child: Text('تجاري')),
                  DropdownMenuItem(value: 'OFFICE', child: Text('مكتب')),
                ],
                onChanged: (v) => setState(() => _propertyType = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _listingType,
                decoration: InputDecoration(
                  labelText: 'نوع العرض',
                  prefixIcon: const Icon(Icons.swap_horiz),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'SALE', child: Text('بيع')),
                  DropdownMenuItem(value: 'RENT_MONTHLY', child: Text('إيجار شهري')),
                  DropdownMenuItem(value: 'RENT_DAILY', child: Text('إيجار يومي')),
                ],
                onChanged: (v) => setState(() => _listingType = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _city,
                decoration: InputDecoration(
                  labelText: 'المدينة',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _city = v),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'الميزانية التقريبية (ليرة سوري)',
                controller: _budgetController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money),
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'نشر الطلب',
                onPressed: _submitRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: Call request provider to submit
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نشر الطلب بنجاح'), backgroundColor: AppColors.success),
    );
    Navigator.of(context).pop();
  }
}