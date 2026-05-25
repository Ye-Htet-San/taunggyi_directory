// ignore_for_file: depend_on_referenced_packages, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';
import 'package:tgi_directory/features/reviews/application/providers/reviews_provider.dart';
// import 'package:tgi_directory/features/reviews/presentation/rate_and_review.dart';
import 'package:tgi_directory/features/reviews/widgets/build_reaction_button.dart';
import 'package:tgi_directory/features/reviews/widgets/user_avatar.dart';

class ReviewsSection extends ConsumerStatefulWidget {
  final int placeId;
  const ReviewsSection({super.key, required this.placeId});

  @override
  ConsumerState<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends ConsumerState<ReviewsSection> {
  final Map<String, bool> _expandedReviews = {};
  String? myUserId;

  @override
  void initState() {
    super.initState();
    // Load Reviews for this place

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Get Auth account info
      final accountInfo = await AuthService().getAccountInfo();

      // Check of still mounted before updating variable ,Exist if widget was disposed while waiting
      if (!mounted) return;
      myUserId = accountInfo?['userId']?.toString();

      // load all reviews
      await ref.read(reviewsProvider.notifier).loadFromBackend(widget.placeId);

      // Final mounted check before setState
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ref.watch(reviewsProvider);
    // final limitedReviews = reviews.take(3).toList(); // Show only 3 reviews here

    // ✅ Exclude the current user's review
    final placeReviews =
        reviews
            .where(
              (r) => r.placeId == widget.placeId.toString() && !r.isMyReview,
            )
            .toList();

    // Limit to 3 reviews
    final limitedReviews =
        placeReviews.length > 3 ? placeReviews.sublist(0, 3) : placeReviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reviews", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        // If no reviews, show a friendly message
        if (placeReviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "No reviews yet. Be the first to review!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...limitedReviews.map((review) {
            final isExpanded = _expandedReviews[review.id] ?? false;

            print(limitedReviews);
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
                                    color: Colors.amber,
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
                            isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
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
                          onTap: () async {
                            final token = await AuthService().getToken();
                            if (token != null) {
                              await ref
                                  .read(reviewsProvider.notifier)
                                  .reactReview(
                                    reviewId: int.parse(review.id),
                                    reactionType: "like",
                                    token: token,
                                  );
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        BuildReactionButton(
                          icon: Icons.thumb_down_alt_outlined,
                          count: review.dislikes,
                          color: Colors.red,
                          onTap: () async {
                            final token = await AuthService().getToken();
                            if (token != null) {
                              await ref
                                  .read(reviewsProvider.notifier)
                                  .reactReview(
                                    reviewId: int.parse(review.id),
                                    reactionType: "dislike",
                                    token: token,
                                  );
                            }
                          },
                        ),
                        const Spacer(),
                        // if (review.isMyReview)
                        //   TextButton(
                        //     onPressed: () async {
                        //       final updated = await Navigator.of(
                        //         context,
                        //       ).push<bool>(
                        //         MaterialPageRoute(
                        //           builder:
                        //               (_) => RateAndReview(
                        //                 placeId: widget.placeId.toString(),
                        //                 reviewId: int.parse(review.id),
                        //                 initialRating: review.rating,
                        //                 initialCommment: review.comment,
                        //               ),
                        //         ),
                        //       );
                        //       if (updated == true) {
                        //         await ref
                        //             .read(reviewsProvider.notifier)
                        //             .loadFromBackend(widget.placeId);
                        //       }
                        //     },
                        //     child: const Text("Edit"),
                        //   ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

        // "See All Reviews" Button
        if (placeReviews.length > 3)
          TextButton(
            onPressed: () {
              context.pushNamed('allReviews');
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
