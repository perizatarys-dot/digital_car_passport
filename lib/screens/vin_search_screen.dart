import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../services/car_service.dart';
import '../services/mock_data.dart';
import '../services/vin_scan_service.dart';
import 'vin_camera_scanner_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_feedback.dart';

class VinSearchScreen extends StatefulWidget {
  const VinSearchScreen({super.key});

  @override
  State<VinSearchScreen> createState() => _VinSearchScreenState();
}

class _VinSearchScreenState extends State<VinSearchScreen> {
  final _controller = TextEditingController(text: MockData.sampleVin);
  final _imagePicker = ImagePicker();
  bool _loading = false;
  String? _error;

  String _sanitizeVin(String value) {
    final cleaned = value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return cleaned.length > 17 ? cleaned.substring(0, 17) : cleaned;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setVin(String vin, {String? message}) {
    final sanitized = _sanitizeVin(vin);
    setState(() {
      _controller.text = sanitized;
      _controller.selection = TextSelection.collapsed(
        offset: sanitized.length,
      );
      _error = null;
    });
    if (message != null) {
      AppFeedback.showMessage(context, message);
    }
  }

  Future<void> _extractVinFromPath(
    String path, {
    required String successMessage,
    required String sourceLabel,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final vin = await VinScanService.extractVinFromImagePath(path);
    if (!mounted) return;

    setState(() => _loading = false);

    if (vin == null) {
      AppFeedback.showMessage(
        context,
        'No valid VIN found in the selected $sourceLabel. Try a clearer image.',
      );
      return;
    }

    _setVin(vin, message: successMessage);
  }

  Future<void> _pickVinFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'],
    );

    if (!mounted || result == null) return;
    final path = result.files.single.path;
    if (path == null) {
      AppFeedback.showMessage(context, 'The selected file could not be opened.');
      return;
    }

    await _extractVinFromPath(
      path,
      successMessage: 'VIN imported from file successfully.',
      sourceLabel: 'file',
    );
  }

  Future<void> _pickVinFromGallery() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (!mounted || file == null) return;

    await _extractVinFromPath(
      file.path,
      successMessage: 'VIN imported from gallery successfully.',
      sourceLabel: 'image',
    );
  }

  Future<void> _openUploadVin() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upload VIN', style: AppTextStyles.h4),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Choose a real image file or photo from your device. The app will read the VIN using OCR.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.folder_open_rounded, color: AppColors.blueAccent),
                  title: const Text('Choose image file'),
                  subtitle: const Text('Open a JPG, PNG, WEBP, or HEIC file'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickVinFile();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.blueAccent),
                  title: const Text('Select from gallery'),
                  subtitle: const Text('Pick a photo that contains the VIN'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickVinFromGallery();
                  },
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(sheetContext);
                    final data = await Clipboard.getData('text/plain');
                    if (!mounted) return;
                    navigator.pop();
                    final pasted = data?.text?.trim() ?? '';
                    if (pasted.isEmpty) {
                      AppFeedback.showMessage(
                        context,
                        'Clipboard is empty. Copy a VIN first.',
                      );
                      return;
                    }
                    _setVin(
                      pasted,
                      message: 'VIN pasted from clipboard.',
                    );
                  },
                  icon: const Icon(Icons.content_paste_go_rounded),
                  label: const Text('Paste VIN manually'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openScanner() async {
    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const VinCameraScannerScreen(),
      ),
    );

    if (!mounted || path == null) return;

    await _extractVinFromPath(
      path,
      successMessage: 'VIN scanned from camera successfully.',
      sourceLabel: 'camera image',
    );
  }

  Future<void> _runSearch() async {
    final vin = _sanitizeVin(_controller.text.trim());
    if (!CarService.validateVin(vin)) {
      setState(() {
        _error = 'Please enter a valid 17-character VIN.';
      });
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;

    setState(() => _loading = false);
    context.push('/report/$vin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.blueDark, AppColors.blueMid],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Search by VIN', style: AppTextStyles.h1White),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Upload, paste, or manually enter the VIN to generate a full Kazakhstan used-car report.',
                    style: AppTextStyles.body.copyWith(color: AppColors.white60),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vehicle identification number', style: AppTextStyles.label),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _controller,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 17,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                            LengthLimitingTextInputFormatter(17),
                          ],
                          onChanged: (value) {
                            final sanitized = _sanitizeVin(value);
                            if (sanitized != value) {
                              _controller.value = TextEditingValue(
                                text: sanitized,
                                selection: TextSelection.collapsed(
                                  offset: sanitized.length,
                                ),
                              );
                            }
                            setState(() => _error = null);
                          },
                          onSubmitted: (_) {
                            if (CarService.validateVin(_controller.text.trim())) {
                              _runSearch();
                            }
                          },
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Courier',
                            letterSpacing: 1,
                          ),
                          decoration: InputDecoration(
                            hintText: 'XTA21140002345678',
                            counterText: '${_controller.text.length}/17',
                            errorText: _error,
                            helperText: 'Use 17 letters/numbers. I, O, and Q are not allowed.',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ExampleChip(
                              text: 'Use sample VIN',
                              onTap: () {
                                setState(() {
                                  _controller.text = MockData.sampleVin;
                                  _error = null;
                                });
                              },
                            ),
                            const _StaticHintChip(text: '1. Enter VIN'),
                            const _StaticHintChip(text: '2. Review report'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _openUploadVin,
                                icon: const Icon(Icons.upload_file_outlined),
                                label: const Text('Upload VIN'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _openScanner,
                                icon: const Icon(Icons.qr_code_scanner_rounded),
                                label: const Text('Scan VIN'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton(
                          onPressed: _loading ||
                                  !CarService.validateVin(_controller.text.trim())
                              ? null
                              : _runSearch,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Text('Generate Full Report'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.white15),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Where to find the VIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10),
                        _VinTip('Dashboard near the windshield'),
                        _VinTip('Driver-side door jamb sticker'),
                        _VinTip('Vehicle registration documents'),
                        _VinTip('Insurance policy or import paperwork'),
                      ],
                    ),
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

class _VinTip extends StatelessWidget {
  final String text;

  const _VinTip(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.teal, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: AppColors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _ExampleChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: AppColors.surface2,
      label: Text(
        text,
        style: const TextStyle(
          color: AppColors.blueAccent,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _StaticHintChip extends StatelessWidget {
  final String text;

  const _StaticHintChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
