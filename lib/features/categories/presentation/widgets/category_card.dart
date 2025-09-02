import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String? iconName;
  final VoidCallback onTap;
  const CategoryCard({
    super.key,
    required this.title,
    required this.iconName,
    required this.onTap,
  });

  // Map string names from your database to Flutter IconData
  IconData _getIcon(String? name) {
    switch (name?.toLowerCase()) {
      case 'hotel':
        return Icons.hotel;
      case 'restaurant':
        return Icons.restaurant;
      case 'museum':
        return Icons.museum;
      case 'park':
        return Icons.park;
      case 'shopping':
        return Icons.shopping_bag;
      case 'cafe':
        return Icons.coffee;
      case 'bar':
        return Icons.local_bar;
      case 'hospital':
        return Icons.local_hospital;
      case 'bank':
        return Icons.account_balance;
      case 'gas station':
        return Icons.local_gas_station;
      case 'library':
        return Icons.local_library;
      case 'pharmacies':
        return Icons.local_pharmacy;
      case 'transport':
        return Icons.directions_bus;
      case 'school':
        return Icons.school;
      case 'cinema':
        return Icons.movie;
      case 'gym':
        return Icons.fitness_center;
      case 'religious':
        return Icons.temple_buddhist;
      // add more mappings if needed
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : Colors.grey.shade200,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(iconName), size: 25, color: Colors.blue),

            SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
