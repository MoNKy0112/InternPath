import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final bool showName;
  final double size;
  final Color? textColor;
  const LogoWidget({
    super.key,
    this.showName = false,
    this.size = 100.0,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Replace with your logo image or widget
          Icon(Icons.school, size: size, color: textColor ?? Colors.blue),
          SizedBox(height: 16),
          if (showName)
            Text(
              'InternPath',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: textColor ?? Colors.blue,
              ),
            ),
        ],
      ),
    );
  }
}
