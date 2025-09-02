import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShortTag extends StatelessWidget {
  const ShortTag({super.key});

  @override
  Widget build(BuildContext context) {
    final currentTagline = GoRouterState.of(context).extra as String;

    final taglineController = TextEditingController(text: currentTagline);

    final cardColor = Theme.of(context).cardColor;
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Short Tagline'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(taglineController.text);
            },
            child: Text('Done', style: TextStyle(color: primary,
            fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 24),
        child: Center(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                if(!isDark)
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3)
                  )
              ]
            ),
            child: TextField(
              controller: taglineController,
              maxLength: 50,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter your short tagline...",
                ),
            ),
          ),
        ),
      ),
    );
  }
}
