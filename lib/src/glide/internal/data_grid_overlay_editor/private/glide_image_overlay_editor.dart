// Port of `packages/core/src/internal/data-grid-overlay-editor/private/
// image-overlay-editor.tsx`.
//
// Web mounts `react-responsive-carousel` with `<img>` children; Flutter's
// `PageView` gives the same swipe-between-images behaviour when there is more
// than one URL. `renderImage` has no equivalent here — `Image.network` is the
// only renderer this package ships.
import 'package:flutter/material.dart';

/// `ImageOverlayEditor` (`image-overlay-editor.tsx:18-45`).
class GlideImageOverlayEditor extends StatelessWidget {
  const GlideImageOverlayEditor({
    super.key,
    required this.urls,
    required this.canWrite,
    required this.onCancel,
    required this.onChange,
    this.onEditClick,
  });

  final List<String> urls;
  final bool canWrite;
  final void Function() onCancel;
  final void Function(String newImage) onChange;
  final void Function()? onEditClick;

  @override
  Widget build(BuildContext context) {
    final filtered = [for (final url in urls) if (url.isNotEmpty) url];
    if (filtered.isEmpty) return const SizedBox.shrink();

    final allowMove = filtered.length > 1;
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          PageView(
            scrollDirection: Axis.horizontal,
            physics: allowMove
                ? null
                : const NeverScrollableScrollPhysics(),
            children: [
              for (final url in filtered)
                Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Text('image failed'),
                  ),
                ),
            ],
          ),
          if (canWrite && onEditClick != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onEditClick,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.edit, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
