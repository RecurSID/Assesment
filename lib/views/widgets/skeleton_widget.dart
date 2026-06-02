import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkCardColor
            : Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
    );
  }
}

class SkeletonLoadingWidget extends StatelessWidget {
  final String? message;

  const SkeletonLoadingWidget({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.56,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(
                          height: constraints.maxWidth / 2.7,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        const SizedBox(height: 12),
                        const SkeletonBox(
                          width: double.infinity,
                          height: 18,
                        ),
                        const SizedBox(height: 8),
                        const SkeletonBox(
                          width: 80,
                          height: 18,
                        ),
                      ],
                    );
                  },
                ),
                if (message != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
