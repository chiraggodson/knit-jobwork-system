import 'package:flutter/material.dart';

class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveWrap({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children,
    );
  }
}
