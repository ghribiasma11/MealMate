import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar variants for the culinary application
enum CustomAppBarVariant {
  /// Standard app bar with title and optional actions
  standard,

  /// Search app bar with search field
  search,

  /// Cooking mode app bar with timer and controls
  cooking,

  /// Recipe detail app bar with favorite and share actions
  recipeDetail,
}

/// A custom app bar widget that provides consistent styling and functionality
/// across the culinary application with support for different variants.
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String? title;

  /// The variant of the app bar to display
  final CustomAppBarVariant variant;

  /// Whether to show the back button
  final bool showBackButton;

  /// Custom leading widget (overrides showBackButton)
  final Widget? leading;

  /// List of action widgets to display
  final List<Widget>? actions;

  /// Callback for search text changes (search variant only)
  final ValueChanged<String>? onSearchChanged;

  /// Initial search text (search variant only)
  final String? initialSearchText;

  /// Whether the recipe is favorited (recipeDetail variant only)
  final bool? isFavorite;

  /// Callback for favorite button tap (recipeDetail variant only)
  final VoidCallback? onFavoritePressed;

  /// Callback for share button tap (recipeDetail variant only)
  final VoidCallback? onSharePressed;

  /// Cooking timer text (cooking variant only)
  final String? timerText;

  /// Whether cooking is paused (cooking variant only)
  final bool? isPaused;

  /// Callback for play/pause button (cooking variant only)
  final VoidCallback? onPlayPausePressed;

  /// Background color override
  final Color? backgroundColor;

  /// Elevation override
  final double? elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.variant = CustomAppBarVariant.standard,
    this.showBackButton = true,
    this.leading,
    this.actions,
    this.onSearchChanged,
    this.initialSearchText,
    this.isFavorite,
    this.onFavoritePressed,
    this.onSharePressed,
    this.timerText,
    this.isPaused,
    this.onPlayPausePressed,
    this.backgroundColor,
    this.elevation,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (widget.variant) {
      case CustomAppBarVariant.search:
        return _buildSearchAppBar(context, theme, isDark);
      case CustomAppBarVariant.cooking:
        return _buildCookingAppBar(context, theme, isDark);
      case CustomAppBarVariant.recipeDetail:
        return _buildRecipeDetailAppBar(context, theme, isDark);
      case CustomAppBarVariant.standard:
      default:
        return _buildStandardAppBar(context, theme, isDark);
    }
  }

  /// Builds the standard app bar variant
  Widget _buildStandardAppBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return AppBar(
      title: widget.title != null
          ? Text(
              widget.title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            )
          : null,
      leading: widget.leading ??
          (widget.showBackButton ? _buildBackButton(context, isDark) : null),
      actions: widget.actions,
      backgroundColor:
          widget.backgroundColor ?? (isDark ? const Color(0xFF1A202C) : Colors.white),
      foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
      elevation: widget.elevation ?? 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  /// Builds the search app bar variant
  Widget _buildSearchAppBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return AppBar(
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3748) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF64748B) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: TextField(
          controller: TextEditingController(text: widget.initialSearchText),
          onChanged: widget.onSearchChanged,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: 'Search recipes, ingredients...',
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: const Color(0xFF64748B),
              size: 20,
            ),
            suffixIcon: widget.initialSearchText?.isNotEmpty == true
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                    onPressed: () {
                      widget.onSearchChanged?.call('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
      leading: _buildBackButton(context, isDark),
      actions: widget.actions,
      backgroundColor:
          widget.backgroundColor ?? (isDark ? const Color(0xFF1A202C) : Colors.white),
      elevation: widget.elevation ?? 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  /// Builds the cooking mode app bar variant
  Widget _buildCookingAppBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return AppBar(
      title: Row(
        children: [
          if (widget.timerText != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF8A00).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: const Color(0xFFFF8A00),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.timerText!,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFF8A00),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (widget.title != null)
            Expanded(
              child: Text(
                widget.title!,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
      leading: _buildBackButton(context, isDark),
      actions: [
        if (widget.onPlayPausePressed != null)
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onPlayPausePressed!();
            },
            icon: Icon(
              widget.isPaused == true ? Icons.play_arrow : Icons.pause,
              color: const Color(0xFFFF8A00),
              size: 24,
            ),
            tooltip: widget.isPaused == true ? 'Resume' : 'Pause',
          ),
        ...?widget.actions,
      ],
      backgroundColor:
          widget.backgroundColor ?? (isDark ? const Color(0xFF1A202C) : Colors.white),
      elevation: widget.elevation ?? 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  /// Builds the recipe detail app bar variant
  Widget _buildRecipeDetailAppBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return AppBar(
      title: widget.title != null
          ? Text(
              widget.title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            )
          : null,
      leading: _buildBackButton(context, isDark),
      actions: [
        if (widget.onFavoritePressed != null)
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onFavoritePressed!();
            },
            icon: Icon(
              widget.isFavorite == true ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite == true
                  ? const Color(0xFFE91E63)
                  : const Color(0xFF64748B),
              size: 24,
            ),
            tooltip: widget.isFavorite == true
                ? 'Remove from favorites'
                : 'Add to favorites',
          ),
        if (widget.onSharePressed != null)
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onSharePressed!();
            },
            icon: Icon(
              Icons.share,
              color: const Color(0xFF64748B),
              size: 24,
            ),
            tooltip: 'Share recipe',
          ),
        ...?widget.actions,
      ],
      backgroundColor:
          widget.backgroundColor ?? (isDark ? const Color(0xFF1A202C) : Colors.white),
      elevation: widget.elevation ?? 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  /// Builds a consistent back button
  Widget _buildBackButton(BuildContext context, bool isDark) {
    return IconButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      icon: Icon(
        Icons.arrow_back,
        color: isDark ? Colors.white : const Color(0xFF1E293B),
        size: 24,
      ),
      tooltip: 'Back',
    );
  }
}