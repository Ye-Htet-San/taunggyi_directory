import 'package:flutter/material.dart';
import 'package:tgi_directory/features/home/data/models/event.dart';
import 'package:tgi_directory/features/home/presentation/widgets/section_title.dart';

class UpcomingEventSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Event> places;
  const UpcomingEventSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SectionTitle(title: title),
            Spacer(),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: TextStyle(fontSize: 14, color: Colors.blue[800]),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(fontSize: 13,),
          ),
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            itemBuilder: (context, index) {
              final event = places[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black45
                                  : Colors.grey.shade300,
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            child: Image.asset(
                              event.images[0],
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              cacheWidth: 512,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.subtitle,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    color: Colors.blue,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${event.date.day.toString().padLeft(2, '0')},${event.date.month.toString().padLeft(2, '0')},${event.date.year}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
