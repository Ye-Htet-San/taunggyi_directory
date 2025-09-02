import 'package:flutter/material.dart';

class EditableCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? child;
  final VoidCallback? onTap;

  const EditableCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: Theme.of(context).brightness== Brightness.dark ? 2: 4,
      child:ListTile(
        leading: Icon(icon,
        color: iconColor,),
        title: Text(
          title,
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold
          ),
        ),
        subtitle: child ?? (subtitle != null ? Text(subtitle!,
        style: textTheme.bodySmall,):
        null),
        trailing: onTap != null? const Icon(Icons.arrow_forward_ios,size: 16,): null,
        onTap: onTap,
      ) ,
      
      );
  }
}
