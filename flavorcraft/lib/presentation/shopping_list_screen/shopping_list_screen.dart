import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../data/services/app_api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_scaffold.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen>
    with SingleTickerProviderStateMixin {
  final AppApiService _appApiService = AppApiService();
  late final AnimationController _animController;

  Map<String, List<Map<String, dynamic>>> _shoppingList = {};
  final Map<String, bool> _expandedCategories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is List<String> && args.isNotEmpty) {
        await _appApiService.generateShoppingList(missingIngredients: args);
      }
      await _loadShoppingList();
    });
  }

  Future<void> _loadShoppingList() async {
    final data = await _appApiService.getShoppingList();
    if (!mounted) return;

    final grouped = data['grouped'] as List<dynamic>? ?? const [];
    final shoppingMap = <String, List<Map<String, dynamic>>>{};
    for (final group in grouped.whereType<Map<String, dynamic>>()) {
      final category = group['category'] as String? ?? 'other';
      final items = (group['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      shoppingMap[category] = items;
      _expandedCategories.putIfAbsent(category, () => true);
    }

    setState(() {
      _shoppingList = shoppingMap;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int get _totalItems => _shoppingList.values.expand((items) => items).length;

  int get _checkedItems => _shoppingList.values
      .expand((items) => items)
      .where((item) => item['is_checked'] as bool? ?? false)
      .length;

  Future<void> _toggleItem(Map<String, dynamic> item) async {
    final id = (item['id'] as num?)?.toInt();
    if (id == null) return;
    await _appApiService.updateShoppingItem(
      itemId: id,
      isChecked: !(item['is_checked'] as bool? ?? false),
    );
    await _loadShoppingList();
  }

  Future<void> _deleteItem(Map<String, dynamic> item) async {
    final id = (item['id'] as num?)?.toInt();
    if (id == null) return;
    await _appApiService.deleteShoppingItem(id);
    await _loadShoppingList();
  }

  Future<void> _addItem() async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controller, autofocus: true),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;
                  final navigator = Navigator.of(context);
                  await _appApiService.addShoppingItem(ingredientName: name);
                  if (navigator.mounted) {
                    navigator.pop();
                  }
                },
                child: const Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
    await _loadShoppingList();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 2,
      child: Scaffold(
        backgroundColor: AppTheme.softBackground,
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                )
              : Column(
                  children: [
                    _buildHeader(),
                    _buildProgressBar(),
                    Expanded(
                      child: ListView(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        children: _shoppingList.keys.map(_buildCategorySection).toList(),
                      ),
                    ),
                    _buildBottomButton(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shopping List',
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  '$_checkedItems of $_totalItems items',
                  style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.mediumGray),
                ),
              ],
            ),
          ),
          IconButton(onPressed: _addItem, icon: const Icon(Icons.add)),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _totalItems > 0 ? _checkedItems / _totalItems : 0.0;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.5.h),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppTheme.lightGray,
        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
        minHeight: 6,
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final items = _shoppingList[category] ?? const [];
    final isExpanded = _expandedCategories[category] ?? true;
    final checkedCount = items.where((item) => item['is_checked'] == true).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(category),
            subtitle: Text('$checkedCount/${items.length}'),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  _expandedCategories[category] = !isExpanded;
                });
              },
              icon: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
            ),
          ),
          if (isExpanded)
            ...items.map((item) {
              final isChecked = item['is_checked'] as bool? ?? false;
              return Dismissible(
                key: Key('item-${item['id']}'),
                onDismissed: (_) => _deleteItem(item),
                background: Container(color: AppTheme.errorRed.withValues(alpha: 0.1)),
                child: ListTile(
                  onTap: () => _toggleItem(item),
                  leading: Icon(
                    isChecked
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isChecked ? AppTheme.primaryGreen : AppTheme.mediumGray,
                  ),
                  title: Text(item['ingredient_name'] as String? ?? ''),
                  trailing: Text(item['quantity'] as String? ?? ''),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 12, 4.w, 3.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _addItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Add Item',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
