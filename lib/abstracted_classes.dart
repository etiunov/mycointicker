import 'package:flutter/cupertino.dart';

// class RateHistory {
//   final double timeScaleX;
//   final double rateScaleY;
//
//   RateHistory({@required this.timeScaleX, @required this.rateScaleY});
// }

class Delegate extends SliverPersistentHeaderDelegate {
  final Widget delegateChild;
  final double maxE;
  final double minE;

  Delegate({
    this.maxE,
    this.minE,
    this.delegateChild,
  });

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(
        child: delegateChild,
      );

  @override
  double get maxExtent => maxE;

  @override
  double get minExtent => minE;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
