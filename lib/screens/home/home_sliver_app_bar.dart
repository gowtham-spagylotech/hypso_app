import 'package:flutter/material.dart';
import 'package:hypso/screens/home/home_swiper.dart';
import 'package:hypso/screens/home/search_bar.dart';


class AppBarHomeSliver extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final List<String>? banners;
  final VoidCallback onSearch;


  AppBarHomeSliver({
    required this.expandedHeight,
    required this.onSearch,
    this.banners,
  });

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        HomeSwipe(
          images: banners,
          height: expandedHeight,
        ),
        Container(
          height: 28,
          color: Theme.of(context).colorScheme.background,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: HomeSearchBar(
            onSearch: onSearch
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 115;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
