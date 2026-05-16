// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tgi_directory/features/reviews/application/providers/reviews_provider.dart';
import 'package:tgi_directory/features/reviews/data/models/review.dart';
import 'package:tgi_directory/features/reviews/widgets/user_avatar.dart';

class AllReviewsPage extends ConsumerStatefulWidget {
  const AllReviewsPage({super.key});

  @override
  ConsumerState<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends ConsumerState<AllReviewsPage> {
  final Set<int> expandedIndexes = {}; //Tracking expanded items

  int? selectedRating; // null = show all

  final List<int?> ratingOptions = [null, 5, 4, 3, 2, 1]; // Filter options

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final reviews = ref.watch(reviewsProvider);

    // Sort by latest review first
    final sortedReviews = List<Review>.from(reviews)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Rating filter
    final filteredReviews =
        selectedRating == null
            ? sortedReviews
            : sortedReviews
                .where((r) => r.rating.round() == selectedRating)
                .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("All Reviews")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Rating filter chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ratingOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),

              itemBuilder: (context, index) {
                final rating = ratingOptions[index];
                final isSelected = rating == selectedRating;
                final label = rating == null ? "All" : "$rating ★";
                return ChoiceChip(
                  label: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white :(isDark? Colors.white70:Colors.black87 ) ,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.blue,
                  backgroundColor:isDark?  Colors.grey[800] : Colors.grey[200],
                  onSelected: (_) {
                    setState(() {
                      selectedRating = rating;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredReviews.length,
              itemBuilder: (context, index) {
                final review = filteredReviews[index];
                final isExpanded = expandedIndexes.contains(index);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header Row: Avatar, Name, Date, Rating
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserAvatar(
                              userName: review.userName,
                              userAvatar: review.userAvatar,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        review.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        DateFormat(
                                          'MMM d, yyyy',
                                        ).format(review.date),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < review.rating.round()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.orange,
                                        size: 18,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// Expandable Comment
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                expandedIndexes.remove(index);
                              } else {
                                expandedIndexes.add(index);
                              }
                            });
                          },
                          child: Text(
                            review.comment,
                            maxLines: isExpanded ? null : 3,
                            overflow:
                                isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (review.comment.length >
                            100) // Show "Read more" only for long text
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  expandedIndexes.remove(index);
                                } else {
                                  expandedIndexes.add(index);
                                }
                              });
                            },
                            child: Text(
                              isExpanded ? "Show less" : "Read more",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                              ),
                            ),
                          ),

                        const SizedBox(height: 8),

                        /// Likes & Dislikes
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(review.likes.toString()),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.thumb_down_alt_outlined,
                              size: 18,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(review.dislikes.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
