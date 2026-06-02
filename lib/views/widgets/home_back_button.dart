import 'package:flutter/material.dart';
import '../../core/icons/huge_icons.dart';

class HomeBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HomeBackButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        shadowColor: Theme.of(context).shadowColor,
        elevation: 2,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              HugeIcons.strokeroundedArrowLeft02,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
