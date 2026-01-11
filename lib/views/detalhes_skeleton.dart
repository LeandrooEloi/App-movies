import 'package:flutter/material.dart';
import '../widgets/skeleton_widget.dart';

class DetalhesSkeleton extends StatelessWidget {
  const DetalhesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SkeletonWidget(
          height: 220,
          borderRadius: BorderRadius.zero,
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonWidget(width: 110, height: 165),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonWidget(height: 22, borderRadius: BorderRadius.all(Radius.circular(8))),
                    SizedBox(height: 10),
                    SkeletonWidget(width: 90, height: 16, borderRadius: BorderRadius.all(Radius.circular(8))),
                    SizedBox(height: 10),
                    SkeletonWidget(width: 170, height: 14, borderRadius: BorderRadius.all(Radius.circular(8))),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: SkeletonWidget(height: 34)),
                        SizedBox(width: 10),
                        Expanded(child: SkeletonWidget(height: 34)),
                      ],
                    ),
                    SizedBox(height: 10),
                    SkeletonWidget(width: 140, height: 34),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SkeletonWidget(height: 14, borderRadius: BorderRadius.all(Radius.circular(8))),
              SizedBox(height: 10),
              SkeletonWidget(height: 14, borderRadius: BorderRadius.all(Radius.circular(8))),
              SizedBox(height: 10),
              SkeletonWidget(height: 14, borderRadius: BorderRadius.all(Radius.circular(8))),
              SizedBox(height: 10),
              SkeletonWidget(width: 240, height: 14, borderRadius: BorderRadius.all(Radius.circular(8))),
              SizedBox(height: 18),
            ],
          ),
        ),
      ],
    );
  }
}
