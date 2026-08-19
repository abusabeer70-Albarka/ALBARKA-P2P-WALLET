import 'package:flutter/material.dart';

class AssetLogo extends StatelessWidget {
  final String assetPath;
  final double size;

  const AssetLogo({
    super.key,
    required this.assetPath,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF123D83),
              ),
              child: const Icon(
                Icons.token,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
