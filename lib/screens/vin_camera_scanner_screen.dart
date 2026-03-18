import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class VinCameraScannerScreen extends StatefulWidget {
  const VinCameraScannerScreen({super.key});

  @override
  State<VinCameraScannerScreen> createState() => _VinCameraScannerScreenState();
}

class _VinCameraScannerScreenState extends State<VinCameraScannerScreen> {
  CameraController? _controller;
  bool _initializing = true;
  bool _capturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _initializing = false;
          _error = 'No camera was found on this device.';
        });
        return;
      }

      final preferredCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        preferredCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'Camera access is unavailable. Check permissions and try again.';
      });
    }
  }

  Future<void> _captureVinImage() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }

    setState(() => _capturing = true);
    try {
      final image = await controller.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(image.path);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _capturing = false;
        _error = 'The scan could not be captured. Try holding the VIN closer.';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _initializing
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.blueAccent),
                  )
                : controller != null && controller.value.isInitialized
                ? CameraPreview(controller)
                : const SizedBox.shrink(),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.78),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _capturing ? null : () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                        ),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Live VIN Scan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Align the VIN inside the frame', style: AppTextStyles.h3White),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Point the camera at the dashboard VIN plate or the driver-side door sticker.',
                    style: TextStyle(
                      color: AppColors.white60,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Container(
                      width: 320,
                      height: 132,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.blueAccent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blueAccent.withValues(alpha: 0.2),
                            blurRadius: 22,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Align(
                            child: Container(
                              height: 2,
                              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              color: AppColors.blueAccent.withValues(alpha: 0.75),
                            ),
                          ),
                          const Positioned(
                            left: 16,
                            top: 12,
                            child: _FrameCorner(alignment: Alignment.topLeft),
                          ),
                          const Positioned(
                            right: 16,
                            top: 12,
                            child: _FrameCorner(alignment: Alignment.topRight),
                          ),
                          const Positioned(
                            left: 16,
                            bottom: 12,
                            child: _FrameCorner(alignment: Alignment.bottomLeft),
                          ),
                          const Positioned(
                            right: 16,
                            bottom: 12,
                            child: _FrameCorner(alignment: Alignment.bottomRight),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Color(0xFFFFB4B4),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _capturing ? null : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Back'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _initializing || _capturing ? null : _captureVinImage,
                          icon: _capturing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.camera_alt_rounded),
                          label: Text(_capturing ? 'Capturing...' : 'Capture VIN'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FrameCorner extends StatelessWidget {
  final Alignment alignment;

  const _FrameCorner({required this.alignment});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(
        painter: _FrameCornerPainter(alignment),
      ),
    );
  }
}

class _FrameCornerPainter extends CustomPainter {
  final Alignment alignment;

  _FrameCornerPainter(this.alignment);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (alignment == Alignment.topLeft) {
      path
        ..moveTo(size.width, 0)
        ..lineTo(0, 0)
        ..lineTo(0, size.height);
    } else if (alignment == Alignment.topRight) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomLeft) {
      path
        ..moveTo(0, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height);
    } else {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FrameCornerPainter oldDelegate) {
    return oldDelegate.alignment != alignment;
  }
}
