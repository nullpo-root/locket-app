import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onFlipCamera;
  final VoidCallback onToggleFlash;
  final VoidCallback onPickGallery;
  final bool isFlashOn;
  final bool isCapturing;

  const CameraControls({
    super.key,
    required this.onCapture,
    required this.onFlipCamera,
    required this.onToggleFlash,
    required this.onPickGallery,
    this.isFlashOn = false,
    this.isCapturing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gallery picker button
          IconButton(
            iconSize: 32,
            icon: const Icon(CupertinoIcons.photo_on_rectangle, color: Colors.white),
            onPressed: onPickGallery,
          ),

          // Locket Shutter Button
          GestureDetector(
            onTap: isCapturing ? null : onCapture,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFD500), // Locket iconic gold/yellow
                  width: 5,
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: isCapturing ? 54 : 64,
                  height: isCapturing ? 54 : 64,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // Flip Camera button
          IconButton(
            iconSize: 32,
            icon: const Icon(CupertinoIcons.arrow_2_circlepath, color: Colors.white),
            onPressed: onFlipCamera,
          ),
        ],
      ),
    );
  }
}
