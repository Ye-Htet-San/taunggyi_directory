// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tgi_directory/features/reviews/application/providers/reviews_provider.dart';
import 'package:tgi_directory/features/reviews/widgets/build_reaction_button.dart';
import 'package:tgi_directory/features/reviews/widgets/user_avatar.dart';

class ReviewsSection extends ConsumerStatefulWidget {
  const ReviewsSection({super.key, required int placeId});

  @override
  ConsumerState<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends ConsumerState<ReviewsSection> {
  final Map<String, bool> _expandedReviews = {};

  @override
  Widget build(BuildContext context) {
    final reviews = ref.watch(reviewsProvider);
    final limitedReviews = reviews.take(3).toList(); // Show only 3 reviews here

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reviews", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),

        ...limitedReviews.map((review) {
          final isExpanded = _expandedReviews[review.id] ?? false;

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
                  // Header: Avatar, Name, Date, Rating
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
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('MMM d, yyyy').format(review.date),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
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

                  const SizedBox(height: 10),

                  // Comment text (expand/collapse)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedReviews[review.id] = !isExpanded;
                      });
                    },
                    child: Text(
                      review.comment,
                      maxLines: isExpanded ? null : 3,
                      overflow:
                          isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),

                  if (review.comment.length > 100)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedReviews[review.id] = !isExpanded;
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

                  const SizedBox(height: 10),

                  // Like / Dislike / Edit Buttons
                  Row(
                    children: [
                      BuildReactionButton(
                        icon: Icons.thumb_up_alt_outlined,
                        count: review.likes,
                        color: Colors.green,
                        onTap: () {
                          // TODO: Implement like logic
                        },
                      ),
                      const SizedBox(width: 16),
                      BuildReactionButton(
                        icon: Icons.thumb_down_alt_outlined,
                        count: review.dislikes,
                        color: Colors.red,
                        onTap: () {
                          // TODO: Implement dislike logic
                        },
                      ),
                      const Spacer(),
                      if (review.isMyReview)
                        TextButton(
                          onPressed: () {
                            // TODO: Implement edit review logic
                          },
                          child: const Text("Edit"),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

        // "See All Reviews" Button
        if (reviews.length > 3)
          TextButton(
            onPressed: () {
              context.pushNamed(
                'allReviews'
              );
            },
            child: const Text(
              "See All Reviews",
              style: TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }
}
