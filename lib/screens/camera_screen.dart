import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/friend_model.dart';
import '../services/storage_service.dart';
import '../widgets/camera_controls.dart';
import '../widgets/friend_badge.dart';
import 'photo_preview_screen.dart';
import 'history_screen.dart';
import 'friends_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;
  bool _isCapturing = false;
  String _selectedRecipient = 'all'; // 'all' or friend.id

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) return;

    final camera = widget.cameras[_selectedCameraIndex];
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _cameraController = controller;
      });
    } catch (e) {
      debugPrint('[CameraScreen] Camera init error: $e');
    }
  }

  void _flipCamera() {
    if (widget.cameras.length < 2) return;
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
    });
    _initCamera();
  }

  void _toggleFlash() async {
    if (_cameraController == null) return;
    try {
      final newFlash = !_isFlashOn;
      await _cameraController!.setFlashMode(
        newFlash ? FlashMode.torch : FlashMode.off,
      );
      setState(() {
        _isFlashOn = newFlash;
      });
    } catch (e) {
      debugPrint('[CameraScreen] Flash toggle error: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      // Fallback for emulator / devices without working camera hardware: pick or create a test photo
      _pickFromGallery();
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final XFile file = await _cameraController!.takePicture();
      if (!mounted) return;

      _navigateToPreview(file.path);
    } catch (e) {
      debugPrint('[CameraScreen] Capture photo error: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      _navigateToPreview(pickedFile.path);
    }
  }

  void _navigateToPreview(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoPreviewScreen(
          imagePath: imagePath,
          recipientId: _selectedRecipient,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final friends = StorageService().friends;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile / History button
                  IconButton(
                    icon: const Icon(CupertinoIcons.clock_fill, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                  ),

                  // Friends Count Pill (Opens Friends screen)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FriendsScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.person_2_fill, color: Color(0xFFFFD500), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${friends.length} Friends',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Flash button
                  IconButton(
                    icon: Icon(
                      _isFlashOn ? CupertinoIcons.bolt_fill : CupertinoIcons.bolt_slash_fill,
                      color: _isFlashOn ? const Color(0xFFFFD500) : Colors.white,
                      size: 26,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),

            // Camera Viewfinder (Square rounded like Locket)
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0, // Locket uses 1:1 square viewfinder
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _buildCameraPreview(),
                  ),
                ),
              ),
            ),

            // Friends Selector row (Locket Style)
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // "All Friends" badge
                  GestureDetector(
                    onTap: () => setState(() => _selectedRecipient = 'all'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedRecipient == 'all'
                                    ? const Color(0xFFFFD500)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Color(0xFF2C2C2E),
                              child: Icon(CupertinoIcons.person_3_fill, color: Colors.white, size: 24),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'All Friends',
                            style: TextStyle(
                              color: _selectedRecipient == 'all' ? const Color(0xFFFFD500) : Colors.white70,
                              fontSize: 11,
                              fontWeight: _selectedRecipient == 'all' ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Individual friends
                  ...friends.map((friend) => FriendBadge(
                        friend: friend,
                        isSelected: _selectedRecipient == friend.id,
                        onTap: () => setState(() => _selectedRecipient = friend.id),
                      )),
                ],
              ),
            ),

            // Shutter & Camera Controls
            CameraControls(
              onCapture: _capturePhoto,
              onFlipCamera: _flipCamera,
              onToggleFlash: _toggleFlash,
              onPickGallery: _pickFromGallery,
              isFlashOn: _isFlashOn,
              isCapturing: _isCapturing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      return CameraPreview(_cameraController!);
    }

    // Emulator / No camera fallback placeholder with quick capture button
    return Container(
      color: const Color(0xFF1C1C1E),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.camera, color: Colors.white38, size: 54),
            const SizedBox(height: 12),
            const Text(
              'Camera Ready',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(CupertinoIcons.photo, color: Color(0xFFFFD500)),
              label: const Text(
                'Pick sample from Gallery',
                style: TextStyle(color: Color(0xFFFFD500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
