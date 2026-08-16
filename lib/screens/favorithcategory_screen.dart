import 'package:flutter/material.dart';
import 'package:skincare_app/components/skipbutton.dart';
import 'package:skincare_app/constant/app_colors.dart';
import 'package:skincare_app/constant/app_string.dart';
import 'package:skincare_app/model/category.dart';
import 'package:skincare_app/services/category_preference_service.dart';
import 'package:skincare_app/services/category_service.dart';

class FavoriteCategory extends StatefulWidget {
  const FavoriteCategory({super.key});

  @override
  State<FavoriteCategory> createState() => _FavoriteCategoryState();
}

class _FavoriteCategoryState extends State<FavoriteCategory> {
  List<Category> _categories = [];
  Set<String> _selectedCategoryIds = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final results = await Future.wait([
      CategoryService.instance.list(),
      CategoryPreferenceService.loadCategoryIds(),
    ]);
    if (!mounted) return;

    final response = results[0] as CategoryListResponse;
    final savedCategoryIds = results[1] as Set<int>;
    setState(() {
      _categories = response.status ? response.categories : [];
      _selectedCategoryIds = _categories
          .where((category) => savedCategoryIds.contains(int.tryParse(category.id)))
          .map((category) => category.id)
          .toSet();
      _isLoading = false;
    });
  }

  Future<void> _saveAndContinue(Iterable<String> categoryIds) async {
    setState(() => _isSaving = true);
    await CategoryPreferenceService.saveCategoryIds(categoryIds);
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                AppString.chooseCategory,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                AppString.chooseSub,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.textGrey),
              ),
              const SizedBox(height: 32),
              Expanded(child: _buildCategoryChoices()),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving || _isLoading
                      ? null
                      : () => _saveAndContinue(_selectedCategoryIds),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          AppString.continueBtn,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SkipButton(
                onTap: () {
                  if (!_isSaving && !_isLoading) {
                    _saveAndContinue(const <String>{});
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChoices() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (_categories.isEmpty) {
      return const Center(
        child: Text(
          'Categories could not be loaded. You can continue without preferences.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: _categories.map((category) {
            final isSelected = _selectedCategoryIds.contains(category.id);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategoryIds.remove(category.id);
                  } else {
                    _selectedCategoryIds.add(category.id);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 20,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
