import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'base_layout.dart';

class AboutAmharicLettersScreen extends StatelessWidget {
  const AboutAmharicLettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseLayout(
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: _buildAppBar(context),
        body: const _FuturisticAmharicLettersBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      elevation: 0,
      iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      title: Text(
        'የፊደላት ትርጉም',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      shape: const RoundedRectangleBorder(),
    );
  }
}

class _FuturisticAmharicLettersBody extends StatefulWidget {
  const _FuturisticAmharicLettersBody();

  @override
  State<_FuturisticAmharicLettersBody> createState() =>
      _FuturisticAmharicLettersBodyState();
}

class _FuturisticAmharicLettersBodyState
    extends State<_FuturisticAmharicLettersBody> {
  List<Map<String, dynamic>> _categories = [];
  int _selectedCategoryIndex = 0;
  String _searchText = '';
  bool _loading = true;
  bool _error = false;
  int? _expandedLetterIndex;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/amharic_letters.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      setState(() {
        _categories = jsonData.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  void _toggleExpandLetter(int index) {
    setState(() {
      if (_expandedLetterIndex == index) {
        _expandedLetterIndex = null;
      } else {
        _expandedLetterIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      );
    }
    if (_error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40, color: Colors.grey[500]),
            const SizedBox(height: 16),
            Text(
              'ውሂቡን ማምጣት አልተቻለም',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    if (_categories.isEmpty) {
      return Center(
        child: Text(
          'ምንም ፊደላት አልተገኙም',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    // Flatten all letters from all categories for global search
    List<dynamic> allLetters =
        _categories.expand((cat) => cat['letters'] ?? []).toList();
    final normalizedSearch = _searchText.trim().toLowerCase();
    final bool isSearching = normalizedSearch.isNotEmpty;
    final List<dynamic> letters =
        isSearching
            ? allLetters
            : (_categories.isNotEmpty
                ? _categories[_selectedCategoryIndex]['letters'] ?? []
                : []);
    List<dynamic> filteredLetters;
    if (isSearching) {
      final letterMatches =
          letters.where((item) {
            final letter = (item['letter'] as String).trim().toLowerCase();
            return letter.contains(normalizedSearch);
          }).toList();
      final explanationMatches =
          letters.where((item) {
            final letter = (item['letter'] as String).trim().toLowerCase();
            final explanation =
                (item['explanation'] as String).trim().toLowerCase();
            return !letter.contains(normalizedSearch) &&
                explanation.contains(normalizedSearch);
          }).toList();
      filteredLetters = [...letterMatches, ...explanationMatches];
    } else {
      filteredLetters = letters;
    }

    return Column(
      children: [
        // Header Section
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Description
              Text(
                'የኢትዮጵያ ሊቃውንት ለእያንዳንዱ ፊደል ነገረ ሃይማኖትን የሚገልጥ ትርጉም ሰጥተዋል።',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.8),
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ፊደል ወይም ትርጉም ፈልግ...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    suffixIcon:
                        _searchText.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchText = '';
                                });
                              },
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value.trim();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Categories tabs
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final cat = _categories[idx];
              final isSelected = idx == _selectedCategoryIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = idx;
                    _expandedLetterIndex =
                        null; // Close any expanded letter when changing category
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color:
                          isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat['category'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onBackground,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Letters list
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                filteredLetters.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'ምንም አልተገኘም',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: filteredLetters.length,
                      separatorBuilder:
                          (context, idx) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final item = filteredLetters[idx];
                        return _buildLetterCard(context, item, idx);
                      },
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildLetterCard(BuildContext context, dynamic item, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpanded = _expandedLetterIndex == index;
    final explanation = item['explanation'] ?? '';

    return Material(
      elevation: 0,
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _toggleExpandLetter(index),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Letter badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        item['letter'],
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Letter explanation
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isExpanded
                              ? explanation
                              : '${explanation.substring(0, explanation.length > 100 ? 100 : explanation.length)}${explanation.length > 100 ? '...' : ''}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: colorScheme.outline.withOpacity(0.1),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.history_edu,
                              size: 16,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'የፊደል ትርጉም',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 20,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                // Additional expanded content could go here
              ],
            ],
          ),
        ),
      ),
    );
  }
}
