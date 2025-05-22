// universal_shimmer.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UniversalShimmer extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Widget? shimmerChild;

  const UniversalShimmer({
    Key? key,
    required this.child,
    required this.isLoading,
    this.shimmerChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: shimmerChild ?? child,
    );
  }
}