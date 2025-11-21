import 'package:flutter/material.dart';

class ShareButton extends StatelessWidget {
  final bool isSharing;
  final VoidCallback onPressed;

  const ShareButton({
    super.key,
    required this.isSharing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: isSharing ? Colors.red : Colors.green,
      icon: Icon(isSharing ? Icons.stop : Icons.play_arrow),
      label: Text(isSharing ? 'Stop Sharing' : 'Share Movement'),
    );
  }
}