// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tgi_directory/config/api_config.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';
// import 'package:tgi_directory/features/places/application/services/place_service.dart';
import 'package:tgi_directory/features/reviews/application/services/reviews_service.dart';
import 'package:tgi_directory/features/reviews/widgets/user_avatar.dart';

class RateAndReview extends StatefulWidget {
  final String placeId;
  final int? reviewId; //null =new review ,not null =edit
  final double? initialRating;
  final String? initialCommment;
  final String? userName;
  final String? userAvatar;

  const RateAndReview({
    super.key,
    required this.placeId,
    this.reviewId,
    this.initialRating,
    this.initialCommment,
    this.userName,
    this.userAvatar,
  });

  @override
  State<RateAndReview> createState() => _RateAndReviewState();
}

class _RateAndReviewState extends State<RateAndReview> {
  late String userName;
  late String userAvatar;

  int rating = 0;
  final commentController = TextEditingController();
  bool posting = false;
  bool loadingUser = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialRating != null) rating = widget.initialRating!.toInt();
    if (widget.initialCommment != null) {
      commentController.text = widget.initialCommment!;
    }
    // Read user info form widget fields
    // Try to use passed-in user info; if missing, fetch account info
    userName = widget.userName ?? 'Unknown';
    userAvatar = widget.userAvatar ?? '';
    if ((widget.userName == null) ||
        (widget.userAvatar == null || widget.userAvatar!.isEmpty)) {
      _loadAccountFallback();
    } else {
      loadingUser = false;
    }
  }

  Future<void> _loadAccountFallback() async {
    try {
      final account = await AuthService().getAccountInfo();
      if (account != null) {
        final rawName = account['userName'] ?? account['username'] ?? 'Unknown';
        var rawAvatar = account['avatarPath'] ?? account['profile_image'] ?? '';
        if (rawAvatar != null &&
            rawAvatar.isNotEmpty &&
            rawAvatar.startsWith('/uploads')) {
          rawAvatar = '${ApiConfig.baseIp}$rawAvatar';
        }
        setState(() {
          userName = rawName;
          userAvatar = rawAvatar ?? '';
          loadingUser = false;
        });
        debugPrint('RateAndReview loaded account: $userName - $userAvatar');
        return;
      }
    } catch (e) {
      debugPrint('RateAndReview: error loading account fallback: $e');
    }
    setState(() {
      userName = widget.userName ?? 'Unknown';
      userAvatar = widget.userAvatar ?? '';
      loadingUser = false;
    });
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select a rating")));
      return;
    }

    final token = await AuthService().getToken();
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please Login")));
      return;
    }

    setState(() {
      posting = true;
    });

    try {
      if (widget.reviewId == null) {
        // creating review
        await ReviewService.addReview(
          placeId: int.parse(widget.placeId),
          rating: rating.toDouble(),
          comment: commentController.text.trim(),
          token: token,
        );
      } else {
        // Edit or Updating
        await ReviewService.updateReview(
          reviewId: widget.reviewId!,
          rating: rating.toDouble(),
          comment: commentController.text.trim(),
          token: token,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true); // returnge to details and refresh there
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Review posted")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          posting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // While fetching user info, show a placeholder in avatar area
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reviewId == null ? 'Rate this place' : 'Edit review',
        ),
        actions: [
          TextButton(
            onPressed: posting ? null : _post,
            child:
                posting
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text("Save", style: TextStyle(color: Colors.blue[800])),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                if (loadingUser)
                  const CircleAvatar(radius: 20,
                  backgroundColor: Colors.grey,)
                else
                UserAvatar(userName: userName, userAvatar: userAvatar),

                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Title/Person's name
                      Text(
                        userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        'Review are public and include your account.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Center(
              child: Row(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final filled = index < rating;
                  return IconButton(
                    iconSize: 32,
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                    icon: Icon(
                      filled ? Icons.star : Icons.star_border,
                      color: filled ? Colors.amber : null,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: commentController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Describe your experience (optional)',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),

                border: OutlineInputBorder(),
                // counterText: '${commentController.text.length}/500'
              ),
            ),
          ],
        ),
      ),
    );
  }
}
