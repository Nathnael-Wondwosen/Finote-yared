import 'package:flutter/material.dart';

class LazyLoadingList extends StatelessWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext, int) itemBuilder;

  const LazyLoadingList({
    required this.items,
    required this.itemBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      cacheExtent: 500, // Cache more items
      itemBuilder: (context, index) {
        return itemBuilder(context, index);
      },
    );
  }
}
