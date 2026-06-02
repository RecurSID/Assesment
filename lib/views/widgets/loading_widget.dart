import 'package:flutter/material.dart';
import 'skeleton_widget.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonLoadingWidget(message: message);
  }
}
