import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'base_layout.dart';

class GisotScreen extends StatefulWidget {
  const GisotScreen({super.key});

  @override
  _GisotScreenState createState() => _GisotScreenState();
}

class _GisotScreenState extends State<GisotScreen> {
  late Future<Map<String, List<Map<String, String>>>> _wordsFuture;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _wordsFuture = _loadGeezWords();
  }

  Future<Map<String, List<Map<String, String>>>> _loadGeezWords() async {
    final String jsonString = await rootBundle.loadString(
      'assets/geez_words.json',
    );
    final Map<String, dynamic> data = json.decode(jsonString);
    return data.map(
      (key, value) => MapEntry(
        key,
        (value as List).map((e) => Map<String, String>.from(e)).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return BaseLayout(
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          title: Text(
            'የግዕዝ ግሶች ከነትርጉማቸው',
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          actions: [
            // Remove search icon from AppBar, search will be below explanation
          ],
        ),
        body: FutureBuilder<Map<String, List<Map<String, String>>>>(
          future: _wordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text('ምንም ውሂብ አልተገኘም', style: textTheme.bodyLarge),
              );
            }
            final data = snapshot.data!;
            final sections = data.entries.toList();
            final categories = sections.map((e) => e.key).toList();
            // Filtered sections
            final filteredSections =
                sections
                    .where(
                      (section) =>
                          _selectedCategory == null ||
                          section.key == _selectedCategory,
                    )
                    .map(
                      (section) => MapEntry(
                        section.key,
                        section.value
                            .where(
                              (entry) =>
                                  (entry['geez'] ?? '').toLowerCase().contains(
                                    _searchQuery.trim().toLowerCase(),
                                  ) ||
                                  (entry['meaning'] ?? '')
                                      .toLowerCase()
                                      .contains(
                                        _searchQuery.trim().toLowerCase(),
                                      ),
                            )
                            .toList(),
                      ),
                    )
                    .where((entry) => entry.value.isNotEmpty)
                    .toList();

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Title row with icon beside title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.language,
                      size: 32,
                      color: colorScheme.primary.withOpacity(0.8),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'የግዕዝ ግሶች',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search bar above the explanation
                _SearchBar(
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 16),
                // Horizontal category filter
                _CategoryFilterBar(
                  categories: categories,
                  selected: _selectedCategory,
                  onCategorySelected:
                      (cat) => setState(() => _selectedCategory = cat),
                ),
                const SizedBox(height: 16),
                // Explanation text
                Text(
                  'የግዕዝ ቋንቋ ግሶች በኢትዮጵያ ታሪክ እና ባህል ውስጥ አስፈላጊ ሚና ያላቸው ናቸው። እዚህ በተለያዩ ግዕዝ ግሶች እና ትርጉማቸው ላይ መረጃ ያገኛሉ።',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onBackground,
                    fontSize: 16,
                    height: 1.7,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),
                // Filtered sections
                if (filteredSections.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(
                        'ይቅርታ፣ የተመረጠው ቃል አልተገኘም።',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                else
                  ...filteredSections
                      .map(
                        (section) => _buildSection(
                          section.key,
                          section.value,
                          colorScheme,
                          textTheme,
                        ),
                      )
                      .toList(),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(
    String sectionTitle,
    List<Map<String, String>> words,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Text(
          sectionTitle,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Georgia',
          ),
        ),
        const SizedBox(height: 10),
        ...words
            .map(
              (entry) => _gisotExample(
                entry['geez'] ?? '',
                entry['meaning'] ?? '',
                colorScheme,
                textTheme,
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _gisotExample(
    String geez,
    String meaning,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  geez,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  meaning,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onBackground,
                    fontSize: 16,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom search bar widget
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'የግዕዝ ቃል ይፈልጉ... ',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
      onChanged: onChanged,
    );
  }
}

// Custom horizontal category filter bar
class _CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onCategorySelected;
  const _CategoryFilterBar({
    required this.categories,
    required this.selected,
    required this.onCategorySelected,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: Text('ሁሉም'),
              selected: selected == null,
              onSelected: (_) => onCategorySelected(null),
            );
          }
          final cat = categories[index - 1];
          return ChoiceChip(
            label: Text(cat),
            selected: selected == cat,
            onSelected: (_) => onCategorySelected(cat),
          );
        },
      ),
    );
  }
}

class _DataSearch extends SearchDelegate {
  final Future<Map<String, List<Map<String, String>>>> dataFuture;

  _DataSearch({required this.dataFuture});

  @override
  String get searchFieldLabel => 'የግዕዝ ቃል ይፈልጉ...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<Map<String, List<Map<String, String>>>>(
      future: dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('ምንም ውሂብ አልተገኘም'));
        }

        final data = snapshot.data!;
        final lowerQuery = query.toLowerCase();
        final results =
            data.entries
                .expand((entry) => entry.value)
                .where(
                  (word) =>
                      (word['geez'] ?? '').toLowerCase().contains(lowerQuery) ||
                      (word['meaning'] ?? '').toLowerCase().contains(
                        lowerQuery,
                      ),
                )
                .toList();

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final entry = results[index];
            return ListTile(
              title: Text(entry['geez'] ?? ''),
              subtitle: Text(entry['meaning'] ?? ''),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
