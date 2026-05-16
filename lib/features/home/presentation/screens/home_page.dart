import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tgi_directory/features/home/data/models/sample_events.dart';
import 'package:tgi_directory/features/home/presentation/widgets/ad_carousel.dart';
import 'package:tgi_directory/features/home/presentation/widgets/category_section.dart';
import 'package:tgi_directory/features/home/presentation/widgets/place_section.dart';
import 'package:tgi_directory/features/home/presentation/widgets/upcoming_event_section.dart';
// import 'package:tgi_directory/features/places/data/models/sample_places.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Taunggyi Directory"),
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: IconButton(
              onPressed: () {
                context.push('/home/search-places');
              },
              icon: Icon(Icons.search),
            ),
          ),
        ],
        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     image: DecorationImage(
        //       image: AssetImage(
        //         'assets/images/cherry.png',
        //       ), // cherry PNG
        //       fit: BoxFit.cover,
        //       opacity: 0.2, // subtle effect
        //     ),
        //   ),
        // ),
      ),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(12),
          children: [
            AdCarousel(),
            SizedBox(height: 12),

            CategorySection(title: 'Categories'),
            SizedBox(height: 8),

            PlaceSection(
              //	Known by many people — locally or globally. Often tied to history, culture, or significance.
              title: 'Famous Places',
              // places: samplePlaces,
              subtitle:
                  'Explore top-rated attractions and must-visit destinations!',
            ),
            SizedBox(height: 8),

            PlaceSection(
              //Currently trendy or frequently visited — due to hype, events, social media, etc.
              title: 'Porpular Places',
              // places: samplePlaces,
              subtitle:
                  'Discover spots that locals and tourists love to visit!',
            ),
            SizedBox(height: 8),

            UpcomingEventSection(
              title: 'Upcoming Events',
              subtitle:
                  'Don’t miss exciting festivals, fairs, and cultural happenings!',
              places: upcomingEvents,
            ),
          ],
        ),
      ),
    );
  }
}
