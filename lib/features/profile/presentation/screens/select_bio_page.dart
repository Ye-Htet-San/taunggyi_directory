import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectBioPage extends StatefulWidget {
  final List<String> bioOptions;
  final List<String> selectedBios;

  const SelectBioPage({
    super.key,
    required this.bioOptions,
    required this.selectedBios,
  });

  @override
  State<SelectBioPage> createState() => _SelectBioPageState();
}

class _SelectBioPageState extends State<SelectBioPage> {
  late List<String> selectedBios;

  @override
  void initState() {
    super.initState();
    selectedBios = List.from(widget.selectedBios);
  }

  void toggleBio(String bio) {
    setState(() {
      if (selectedBios.contains(bio)) {
        selectedBios.remove(bio);
      } else if (selectedBios.length < 3) {
        selectedBios.add(bio);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You can select up to 3 interests only')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Interests'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(selectedBios);
            },
            child:Text('Done', style: TextStyle(color:primary,
            fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              widget.bioOptions.map((bio) {
                final isSelected = selectedBios.contains(bio);
                return ChoiceChip(
                  label: Text(bio),
                  labelStyle: TextStyle(
                    color: isSelected? (isDark? Colors.black: Colors.white):null
                  ),
                  selected: isSelected,
                  selectedColor:primary,
                  backgroundColor: cardColor,
                  onSelected: (_) => toggleBio(bio),
                );
              }).toList(),
        ),
      ),
    );
  }
}
