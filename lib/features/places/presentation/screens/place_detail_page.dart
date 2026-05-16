// ignore_for_file: collection_methods_unrelated_type
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tgi_directory/config/url_luncher.dart';
import 'package:tgi_directory/features/auth/application/services/auth_service.dart';
import 'package:tgi_directory/features/favorites/application/providers/favorites_provider.dart';
import 'package:tgi_directory/features/places/application/services/place_service.dart';
import 'package:tgi_directory/features/places/data/models/place.dart';
import 'package:tgi_directory/features/places/presentation/screens/info_row.dart';
import 'package:tgi_directory/features/places/presentation/widgets/name_tag.dart';
import 'package:tgi_directory/features/reviews/application/providers/reviews_provider.dart';
import 'package:tgi_directory/features/reviews/application/services/reviews_service.dart';
import 'package:tgi_directory/features/reviews/data/models/review.dart';
import 'package:tgi_directory/features/reviews/presentation/rate_and_review.dart';
import 'package:tgi_directory/features/reviews/presentation/reviews_section.dart';
import 'package:tgi_directory/features/reviews/widgets/user_avatar.dart';
import 'package:tgi_directory/features/visited/application/providers/visited_provider.dart';

class PlaceDetailPage extends ConsumerStatefulWidget {
  final Place place;

  const PlaceDetailPage({super.key, required this.place});

  @override
  ConsumerState<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends ConsumerState<PlaceDetailPage> {
  final CarouselSliderController _controller = CarouselSliderController();
  int current = 0;

  Review? myReview;
  bool loadingMyReview = true;

  String? userName;
  String? userAvatar;

  bool _isMyReviewExpanded = false; // For expanded comment
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();

    // ✅ Mark visited when opened
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   final token = await AuthService().getToken(); // getting auth token
    //   if (token != null) {
    //     ref.read(visitedProvider.notifier).markVisited(widget.place.id, token);
    //   }
    // });

    _init(); // load both account info and user's review
  }

  Future<void> _init() async {
    // 1) Load account info (if logged in)
    try {
      final account = await AuthService().getAccountInfo();
      if (account != null) {
        final rawName = account['userName'] ?? account['userName'] ?? 'Unknown';
        var rawAvatar = account['avatarPath'] ?? account['profile_image'] ?? '';

        //If backend provides relative path( /uploads/....)
        if (rawAvatar != null &&
            rawAvatar.isNotEmpty &&
            rawAvatar.startsWith('/uploads')) {
          rawAvatar = '${PlaceService.baseUrl}$rawAvatar';
        }
        setState(() {
          userName = rawName;
          userAvatar = rawAvatar ?? '';
        });
        debugPrint('Loaded account -> userName: $userName, $userAvatar');
      }
    } catch (e) {
      debugPrint('Error loading account info: $e');
    }

    // 2) Mark visited + load my review (if logged in)
    final token = await AuthService().getToken();
    if (token != null) {
      try {
        // mark visited (non- blocking)
        ref.read(visitedProvider.notifier).markVisited(widget.place.id, token);

        // Fetch my review
        final review = await ReviewService.getMyReview(widget.place.id, token);
        if (review != null) {
          setState(() {
            myReview = review;
            loadingMyReview = false;
          });
        } else {
          setState(() {
            myReview = null;
            loadingMyReview = false;
          });
        }
      } catch (e) {
        // if 404 or network issue => treat as no review yet
        debugPrint('Error loading my review: $e');
        setState(() {
          myReview = null;
          loadingMyReview = false;
        });
      }
    } else {
      setState(() {
        myReview = null;
        loadingMyReview = false;
      });
    }
  }

  void deleteMyReview() async {
    final token = await AuthService().getToken();
    if (token != null && myReview != null) {
      try {
        await ReviewService.deleteReview(
          reviewId: int.parse(myReview!.id),
          token: token,
        );
        setState(() {
          myReview = null; // reset after deletion
        });
        // Refresh other reviews
        ref.read(reviewsProvider.notifier).loadFromBackend(widget.place.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review deleted successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete review: $e")));
      }
    }
  }

  void toggleFavorite() async {
    final token = await AuthService().getToken();
    if (token != null) {
      ref
          .read(favoritesProvider.notifier)
          .toggleFavorite(widget.place.id, token);
    }
  }

  void navigateToReviewPage() async {
    // If account info hasn't loaded yet, attempt to fetch now (safety)
    if (userName == null || userAvatar == null) {
      try {
        final account = await AuthService().getAccountInfo();
        if (account != null) {
          final rawName =
              account['userName'] ?? account['username'] ?? 'Unknown';
          var rawAvatar =
              account['avatarPath'] ?? account['profile_image'] ?? '';
          if (rawAvatar != null &&
              rawAvatar.isNotEmpty &&
              rawAvatar.startsWith('/uploads')) {
            rawAvatar = '${PlaceService.baseUrl}$rawAvatar';
          }
          userName = rawName;
          userAvatar = rawAvatar ?? '';
        }
      } catch (e) {
        debugPrint('navigateToReviewPage: failed to fetch account: $e');
      }
    }

    // Build argument (prefer myReview values when editing)
    final passedName = myReview?.userName ?? userName ?? 'Unknown';
    final passedAvatar = myReview?.userAvatar ?? userAvatar ?? '';

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => RateAndReview(
              placeId: widget.place.id.toString(),
              reviewId: myReview != null ? int.tryParse(myReview!.id) : null,
              initialRating: myReview?.rating,
              initialCommment: myReview?.comment,
              userName: passedName,
              userAvatar: passedAvatar,
            ),
      ),
    );

    // If posted/updated,refresh local things
    if (result == true) {
      // refresh my review and reviews list
      _init();
      ref.read(reviewsProvider.notifier).loadFromBackend(widget.place.id);
    }
  }

  List<String> formatOpeningHoursStrings(List<String> hours) {
    if (hours.isEmpty) return [];

    // Check if all days are "Open all day"
    bool allDaysOpen = hours.every(
      (h) => h.toLowerCase().contains("open all day"),
    );

    if (allDaysOpen) return ["Open every day"];

    return hours;
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(widget.place.id);

    final reviews = ref.watch(reviewsProvider);
    final reviewCount = reviews.where(
      (r) => r.placeId == widget.place.id.toString()).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.place.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Carousel
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (widget.place.images.isNotEmpty)
                  CarouselSlider(
                    carouselController: _controller,
                    options: CarouselOptions(
                      height: 220,
                      viewportFraction: 0.95,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      onPageChanged: (index, reason) {
                        setState(() {
                          current = index;
                        });
                      },
                    ),
                    items:
                        widget.place.images.map((imagePath) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (_) => Dialog(
                                      backgroundColor:
                                          Colors.black, // dim background
                                      insetPadding: EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 4,
                                      ),
                                      child: Stack(
                                        fit: StackFit.loose,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  '${PlaceService.baseUrl}/$imagePath',
                                              fit:
                                                  BoxFit
                                                      .contain, // keep aspect ratio
                                              placeholder:
                                                  (context, url) => Container(
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: '${PlaceService.baseUrl}/$imagePath',
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.red,
                                      ),
                                    ),
                              ),
                            ),
                          );
                        }).toList(),
                  )
                else
                  Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.grey,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.black54,
                    ),
                  ),
                if (widget.place.images.isNotEmpty)
                  Positioned(
                    bottom: 10,
                    child: Row(
                      children:
                          widget.place.images.asMap().entries.map((e) {
                            return GestureDetector(
                              onTap: () => _controller.animateToPage(e.key),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: current == e.key ? 16 : 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color:
                                      current == e.key
                                          ? Colors.blue
                                          : Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            //Details
            Padding(
              padding: EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Title
                  Text(
                    widget.place.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),

                  //Subcategory
                  // Text(
                  //   widget.place.subcategory ?? '',
                  //   style: TextStyle(fontSize: 14),
                  // ),
                  NameTag(
                    name: widget.place.subcategoryName ?? '',
                    color: Colors.yellow.shade800,
                  ),
                  SizedBox(height: 8),

                  //Rating
                  Row(
                    children: [
                      Text(widget.place.rating.toStringAsFixed(1)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.amber, size: 22),

                      SizedBox(width: 4),
                      Text('($reviewCount) reviews'),

                      Spacer(),

                      IconButton(
                        icon: Icon(Icons.map, color: Colors.blue),
                        onPressed: () {
                          final url =
                              'https://www.google.com/maps/search/?api=1&query=${widget.place.latitude},${widget.place.longitude}';
                          launchExternalUrl(context, url);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  //Description
                  GestureDetector(
                    onTap: () {
                      if (widget.place.description.length > 100) {
                        setState(() {
                          _isDescriptionExpanded = !_isDescriptionExpanded;
                        });
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.place.description,
                          maxLines: _isDescriptionExpanded ? null : 3,
                          overflow:
                              _isDescriptionExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                        if (widget.place.description.length > 100)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _isDescriptionExpanded
                                  ? "Show less"
                                  : "Read more",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Divider(height: 32),

                  //More info
                  InfoRow(
                    icon: Icons.location_on,
                    label: 'Address',
                    values: [widget.place.address],
                  ),
                  if (widget.place.phone.isNotEmpty)
                    InfoRow(
                      icon: Icons.phone,
                      label: 'Phone',
                      values: [widget.place.phone.join(',')],
                    ),
                  if (widget.place.email != null &&
                      widget.place.email!.isNotEmpty)
                    InfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      values: [widget.place.email!],
                      isLink: false, // optional: can tap to send email
                    ),
                  // if(widget.place.)
                  if (widget.place.website.isNotEmpty)
                    InfoRow(
                      icon: Icons.language,
                      label: 'Website',
                      values: [widget.place.website],
                      isLink: true,
                    ),
                  InfoRow(
                    icon: Icons.map,
                    label: 'Coordinates',
                    values: [
                      'Lat: ${widget.place.latitude}',
                      'Lng: ${widget.place.longitude}',
                    ],
                    isLink: true, // optional: tap to open in maps
                  ),

                  if (widget.place.paymentMethods != null &&
                      widget.place.paymentMethods!.isNotEmpty)
                    InfoRow(
                      icon: Icons.payment,
                      label: 'Payment Methods',
                      values: widget.place.paymentMethods!,
                    ),

                  if (widget.place.openingHours.isNotEmpty)
                    InfoRow(
                      icon: Icons.schedule,
                      label: 'Opening Hours',
                      values: formatOpeningHoursStrings(
                        widget.place.openingHours,
                      ),
                    ),

                  const Divider(),

                  // ✅ Conditionally show review input or user review
                  loadingMyReview
                      ? const Center(child: CircularProgressIndicator())
                      : myReview != null
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Review",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              UserAvatar(
                                userName: myReview!.userName,
                                userAvatar: myReview!.userAvatar,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          myReview!.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          DateFormat(
                                            'MMM d, yyyy',
                                          ).format(myReview!.date),
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
                                          i < myReview!.rating.round()
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
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_outlined),
                                onSelected: (value) {
                                  // if (value == 'edit' && myReview != null) {
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder:
                                  //           (_) => RateAndReview(
                                  //             placeId:
                                  //                 widget.place.id.toString(),
                                  //             reviewId: int.tryParse(
                                  //               myReview!.id,
                                  //             ),
                                  //             initialRating: myReview!.rating,
                                  //             initialCommment:
                                  //                 myReview!.comment,
                                  //             userName: myReview!.userName,
                                  //             userAvatar: myReview!.userAvatar,
                                  //           ),
                                  //     ),
                                  //   );
                                  // } else if (value == 'delete') {
                                  //   deleteMyReview();
                                  // }
                                  if (value == 'edit') {
                                    navigateToReviewPage();
                                  } else if (value == 'delete') {
                                    deleteMyReview();
                                  }
                                },
                                itemBuilder:
                                    (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Delete Review'),
                                          ],
                                        ),
                                      ),
                                    ],
                                // (BuildContext context) => [
                                //   PopupMenuItem<String>(
                                //     value: 'edit',
                                //     child: Row(
                                //       children: [
                                //         Icon(
                                //           Icons.edit,
                                //           color: Colors.blue,
                                //         ),
                                //         SizedBox(height: 8),
                                //         Text(
                                //           'Edit',
                                //           style: TextStyle(
                                //             color: Colors.blue[800],
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                //   PopupMenuItem<String>(
                                //     value: 'delete',
                                //     child: Row(
                                //       children: const [
                                //         Icon(
                                //           Icons.delete,
                                //           color: Colors.red,
                                //         ),
                                //         SizedBox(width: 8),
                                //         Text(
                                //           'Delete Review',
                                //           style: TextStyle(
                                //             color: Colors.red,
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMyReviewExpanded = !_isMyReviewExpanded;
                              });
                            },
                            child: Text(
                              myReview!.comment,
                              maxLines: _isMyReviewExpanded ? null : 3,
                              overflow:
                                  _isMyReviewExpanded
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ),
                          if (myReview!.comment.length > 100)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isMyReviewExpanded = !_isMyReviewExpanded;
                                });
                              },
                              child: Text(
                                _isMyReviewExpanded ? "Show less" : "Read more",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                          const SizedBox(height: 4),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Give rating
                          Text(
                            'Rate This Place',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          //Stars
                          Row(
                            children: List.generate(5, (index) {
                              return IconButton(
                                iconSize: 32,
                                icon: Icon(Icons.star_border),
                                onPressed: navigateToReviewPage,
                              );
                            }),
                          ),
                          TextButton(
                            onPressed: navigateToReviewPage,
                            child: Text("Write A Review"),
                          ),
                        ],
                      ),
                  Divider(),

                  //  Other users' reviews
                  ReviewsSection(placeId: widget.place.id),
                  // const SizedBox(height: 8),
                  //Example comments
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
