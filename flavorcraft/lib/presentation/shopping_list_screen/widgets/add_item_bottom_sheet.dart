import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class AddItemBottomSheet extends StatefulWidget {
  final Function(String, String, String, String) onAddItem;

  const AddItemBottomSheet({
    super.key,
    required this.onAddItem,
  });

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedUnit = 'pcs';
  String _selectedCategory = 'Pantry';

  final List<String> _units = [
    'pcs',
    'lbs',
    'oz',
    'kg',
    'g',
    'cups',
    'tbsp',
    'tsp',
    'ml',
    'l',
    'qt',
    'pt'
  ];

  final List<String> _categories = [
    'Produce',
    'Dairy',
    'Meat',
    'Pantry',
    'Bakery',
    'Frozen'
  ];

  final List<String> _recentIngredients = [
    'Milk',
    'Bread',
    'Eggs',
    'Chicken Breast',
    'Tomatoes',
    'Onions',
    'Cheese',
    'Butter',
    'Rice',
    'Pasta',
    'Olive Oil',
    'Salt'
  ];

  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = _recentIngredients;
    _nameController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onSearchChanged);
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _nameController.text.toLowerCase();
    setState(() {
      _filteredSuggestions = query.isEmpty
          ? _recentIngredients
          : _recentIngredients
              .where((ingredient) => ingredient.toLowerCase().contains(query))
              .toList();
    });
  }

  void _addItem() {
    if (_nameController.text.trim().isEmpty) return;

    final quantity = _quantityController.text.trim().isEmpty
        ? '1'
        : _quantityController.text.trim();

    widget.onAddItem(
      _nameController.text.trim(),
      quantity,
      _selectedUnit,
      _selectedCategory,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 4.w,
        right: 4.w,
        top: 2.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 2.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.pureWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Add Item',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.mediumGray,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            'Item Name',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter item name...',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: AppTheme.mediumGray,
                  size: 20,
                ),
              ),
            ),
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
            ),
          ),
          if (_filteredSuggestions.isNotEmpty &&
              _nameController.text.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Container(
              constraints: BoxConstraints(maxHeight: 15.h),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _filteredSuggestions[index];
                  return ListTile(
                    dense: true,
                    leading: CustomIconWidget(
                      iconName: 'history',
                      color: AppTheme.mediumGray,
                      size: 16,
                    ),
                    title: Text(
                      suggestion,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                      ),
                    ),
                    onTap: () {
                      _nameController.text = suggestion;
                      setState(() {
                        _filteredSuggestions = [];
                      });
                    },
                  );
                },
              ),
            ),
          ],
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '1',
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(),
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedUnit = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Category',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.pureWhite : AppTheme.textDark,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accentOrange
                        : (isDark
                            ? AppTheme.cardDark
                            : AppTheme.lightGray.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accentOrange
                          : AppTheme.lightGray,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppTheme.pureWhite
                          : (isDark ? AppTheme.pureWhite : AppTheme.textDark),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addItem,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add to List',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}