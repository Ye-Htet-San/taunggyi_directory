// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:tgi_directory/features/places/application/services/place_service.dart';
import 'package:tgi_directory/features/reviews/application/providers/reviews_provider.dart';
import 'package:tgi_directory/features/reviews/data/models/review.dart';

class MyReviewsPage extends ConsumerWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews =
        ref.watch(reviewsProvider).where((r) => r.isMyReview).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("My Reviews")),
      body:
          reviews.isEmpty
              ? const Center(
                child: Text(
                  "You haven’t written any reviews yet.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return _ReviewCard(review: review);
                },
              ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;

    final date = DateFormat("MMM d, yyyy").format(widget.review.date);

    return FutureBuilder(
      future: PlaceService.getPlaces(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final allPlaces = snapshot.data!;
        final place = allPlaces.firstWhere(
          (p) => p.id == int.parse(widget.review.placeId),
        );

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/place-detail', extra: place),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Place name + date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          place.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        date,
                        style:  TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < widget.review.rating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Comment
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      review.comment,
                      maxLines: _isExpanded ? null : 3,
                      overflow:
                          _isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (review.comment.length > 100)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Text(
                            _isExpanded ? "Show less" : "Read more",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      Spacer(),
                      // View Place button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed:
                              () => context.push('/place-detail', extra: place),
                          child: const Text("View Place"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
