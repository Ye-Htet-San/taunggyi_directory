import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/features/profile/data/township_list.dart';

class SelectLocationPage extends StatefulWidget {
  const SelectLocationPage({super.key});

  @override
  State<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  String query = '';
  List<String> filteredTownships = [];

  @override
  void initState() {
    super.initState();
    filteredTownships = myanmarTownships;
  }

  void updateSearch(String value) {
    setState(() {
      query = value;
      filteredTownships =
          myanmarTownships
              .where((town) => town.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).extra as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56), 
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: updateSearch,
              decoration: InputDecoration(
                hintText: 'Search township...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)
                )
              ),
            ),
            
            )),
        
        
        
        ),
      body: ListView.separated(
        itemCount: filteredTownships.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final town = filteredTownships[index];
          final isSelected = town == currentLocation;

          return ListTile(
            title: Text(town),
            trailing:
                isSelected ? Icon(Icons.check, color: Colors.green) : null,
            onTap: () {
              context.pop(town);
            },
          );
        },
      ),
    );
  }
}
