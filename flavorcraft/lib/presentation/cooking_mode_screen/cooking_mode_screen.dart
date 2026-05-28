import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/recipe.dart';
import './widgets/cooking_step_card_widget.dart';
import './widgets/ingredient_reference_widget.dart';
import './widgets/timer_bar_widget.dart';

class CookingModeScreen extends StatefulWidget {
  const CookingModeScreen({super.key});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen>
    with TickerProviderStateMixin {
  int _currentStepIndex = 0;
  bool _showIngredients = false;
  List<bool> _checkedIngredients = [];
  List<Map<String, dynamic>> _activeTimers = [];
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  Recipe? _recipe;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _keepScreenAwake();
    _initializeMockTimers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecipe());
  }

  void _loadRecipe() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) return;

    try {
      final recipe = Recipe.fromDynamic(args);
      setState(() {
        _recipe = recipe;
        _checkedIngredients =
            List<bool>.filled(recipe.ingredients.length, false);
      });
    } catch (_) {
      // Keep the empty state below if a recipe was not provided.
    }
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
  }

  void _keepScreenAwake() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _initializeMockTimers() {
    _activeTimers = [];
  }

  @override
  void dispose() {
    _slideController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _handlePreviousStep() {
    if (_currentStepIndex > 0) {
      setState(() => _currentStepIndex--);
      HapticFeedback.lightImpact();
    }
  }

  void _handleNextStep() {
    final steps = _recipe?.cookingSteps ?? const <Map<String, dynamic>>[];
    if (_currentStepIndex < steps.length - 1) {
      setState(() => _currentStepIndex++);
      HapticFeedback.lightImpact();
    } else {
      _handleRecipeComplete();
    }
  }

  void _handleRecipeComplete() {
    final recipeTitle = _recipe?.title ?? 'this recipe';
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Recipe Complete!'),
        content: Text(
          'Congratulations! You\'ve successfully completed $recipeTitle.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Done',
              style: TextStyle(color: AppTheme.accentOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _handleStartTimer() {
    final steps = _recipe?.cookingSteps ?? const <Map<String, dynamic>>[];
    final currentStep = steps[_currentStepIndex];
    final timerDuration = currentStep['timer'] as String?;

    if (timerDuration != null && timerDuration.isNotEmpty) {
      setState(() {
        _activeTimers.add({
          'name': 'Step ${_currentStepIndex + 1}',
          'timeRemaining': timerDuration,
          'progress': 0.0,
          'isActive': true,
        });
      });
    }
  }

  void _handleTimerTap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Active Timers'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _activeTimers.length,
            itemBuilder: (context, index) {
              final timer = _activeTimers[index];
              return ListTile(
                title: Text(timer['name'] as String),
                subtitle: Text(timer['timeRemaining'] as String),
                trailing: IconButton(
                  onPressed: () {
                    setState(() => _activeTimers.removeAt(index));
                    Navigator.of(context).pop();
                  },
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.errorRed,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _toggleIngredients() {
    setState(() => _showIngredients = !_showIngredients);
    if (_showIngredients) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  void _handleIngredientToggle(int index) {
    if (index < _checkedIngredients.length) {
      setState(() => _checkedIngredients[index] = !_checkedIngredients[index]);
      HapticFeedback.lightImpact();
    }
  }

  void _handleExitCookingMode() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recipe = _recipe;

    if (recipe == null) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.pureWhite,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Text(
              'Open cooking mode from a recipe detail screen to load recipe data from the database.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
    }

    final steps = recipe.cookingSteps;
    final ingredients =
        recipe.ingredients.map((ingredient) => ingredient.toCookingMap()).toList();
    final currentStep = steps[_currentStepIndex];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.pureWhite,
      body: Stack(
        children: [
          Column(
            children: [
              TimerBarWidget(
                activeTimers: _activeTimers,
                onTimerTap: _handleTimerTap,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: CookingStepCardWidget(
                    currentStep: currentStep,
                    currentStepIndex: _currentStepIndex,
                    totalSteps: steps.length,
                    onPrevious: _handlePreviousStep,
                    onNext: _handleNextStep,
                    onStartTimer: _handleStartTimer,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 2.h,
            left: 4.w,
            child: GestureDetector(
              onTap: _handleExitCookingMode,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.pureWhite,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 2.h,
            right: 4.w,
            child: GestureDetector(
              onTap: _toggleIngredients,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'restaurant',
                  color: AppTheme.pureWhite,
                  size: 20,
                ),
              ),
            ),
          ),
          if (_showIngredients)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleIngredients,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
            ),
          if (_showIngredients)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: GestureDetector(
                  onTap: () {},
                  child: IngredientReferenceWidget(
                    ingredients: ingredients,
                    checkedIngredients: _checkedIngredients,
                    onIngredientToggle: _handleIngredientToggle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
