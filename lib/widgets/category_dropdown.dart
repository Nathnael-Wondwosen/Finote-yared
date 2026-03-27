import 'package:flutter/material.dart';
import '../db_helper.dart';

class CategoryDropdown extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategoryDropdown({required this.onCategorySelected, super.key});

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  bool isExpanded = false;
  List<Map<String, dynamic>> categories = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final loadedCategories = await DBHelper.instance.getCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        'መዝሙር',
        style: TextStyle(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
        ),
      ),
      leading: Icon(
        Icons.music_note,
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
      ),
      children: [
        ...categories.map(
          (category) => ListTile(
            contentPadding: EdgeInsets.only(left: 32),
            title: Text(
              category['category'] as String,
              style: TextStyle(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
              ),
            ),
            selected: selectedCategory == category['category'],
            onTap: () {
              setState(() {
                selectedCategory = category['category'] as String;
              });
              widget.onCategorySelected(category['category'] as String);
            },
          ),
        ),
      ],
    );
  }
}
