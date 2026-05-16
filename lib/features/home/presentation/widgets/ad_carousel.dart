import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AdCarousel extends StatefulWidget {
  const AdCarousel({super.key});

  @override
  State<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();
  int current = 0;

  final List<String> adImages = [
    'assets/ads/montainstarads.jpg',
    'assets/ads/pindaya.jpeg',
    'assets/ads/taunggyihotelads.jpg',
    'assets/ads/upperhouseads.jpeg',
    'assets/ads/InleLake1.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          items:
              adImages.map((imagePath) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
          carouselController: _controller,
          options: CarouselOptions(
            height:
                MediaQuery.of(context).size.height *
                0.25, // 25% of screen height
            aspectRatio: 16 / 9,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction:1,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() {
                current = index;
              });
            },
          ),
        ),
        Positioned(
          bottom: 10,
          child: Row(
            children: adImages.asMap().entries.map((e) {
              return GestureDetector(
                onTap: () =>_controller.animateToPage(e.key) ,
                child: AnimatedContainer(
                  duration:const Duration(milliseconds:300 ) ,
                  width: current == e.key? 16 : 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: current == e.key ? Colors.blue : Colors.white
                  ),
                  ),
              );
            },).toList(),
          ),
        )
      ],
    );
  }
}
