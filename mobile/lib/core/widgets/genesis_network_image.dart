import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../theme/app_colors.dart';

/// A custom Network Image widget that caches image bytes in memory
/// to prevent duplicate network requests (429 Too Many Requests) and
/// optimize performance across all platforms, especially Flutter Web.
class GenesisNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const GenesisNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  // Static in-memory cache to share bytes globally across widgets/screens
  static final Map<String, Uint8List> _bytesCache = {};

  @override
  State<GenesisNetworkImage> createState() => _GenesisNetworkImageState();
}

class _GenesisNetworkImageState extends State<GenesisNetworkImage> {
  Uint8List? _bytes;
  bool _hasError = false;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(GenesisNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _loadImage();
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _loadImage() async {
    if (widget.url.isEmpty) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      return;
    }

    // Check memory cache first
    final cachedBytes = GenesisNetworkImage._bytesCache[widget.url];
    if (cachedBytes != null) {
      if (mounted) {
        setState(() {
          _bytes = cachedBytes;
          _hasError = false;
        });
      }
      return;
    }

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    if (mounted) {
      setState(() {
        _hasError = false;
        _bytes = null;
      });
    }

    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        widget.url,
        cancelToken: _cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'image/*',
          },
        ),
      );

      if (response.data != null) {
        final bytes = Uint8List.fromList(response.data!);
        GenesisNetworkImage._bytesCache[widget.url] = bytes;

        if (mounted) {
          setState(() {
            _bytes = bytes;
          });
        }
      } else {
        throw Exception('Response data was null');
      }
    } catch (e) {
      // Avoid state updates if cancelled
      if (e is DioException && CancelToken.isCancel(e)) return;

      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }

    if (_hasError) {
      return widget.errorWidget ?? Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.navy100,
        child: const Icon(
          Icons.image_not_supported_rounded,
          color: AppColors.textDisabled,
          size: 20,
        ),
      );
    }

    return widget.placeholder ?? Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.navy50,
      child: const Center(
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.navy500,
          ),
        ),
      ),
    );
  }
}
