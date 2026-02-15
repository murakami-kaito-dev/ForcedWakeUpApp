import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';

const _appStoreUrl = 'https://apps.apple.com/app/id6759155359';
const _maxLength = 200;

class ShareEditSheet extends StatefulWidget {
  final String defaultText;
  final AppStrings strings;

  const ShareEditSheet({
    super.key,
    required this.defaultText,
    required this.strings,
  });

  static Future<void> show(BuildContext context,
      {required String defaultText, required AppStrings strings}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ShareEditSheet(
        defaultText: defaultText,
        strings: strings,
      ),
    );
  }

  @override
  State<ShareEditSheet> createState() => _ShareEditSheetState();
}

class _ShareEditSheetState extends State<ShareEditSheet> {
  late final TextEditingController _controller;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultText);
    _charCount = _controller.text.length;
    _controller.addListener(() {
      setState(() => _charCount = _controller.text.length);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _share() {
    final userText = _controller.text.trim();
    final shareText =
        userText.isEmpty ? _appStoreUrl : '$userText\n$_appStoreUrl';
    Navigator.pop(context);
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.shareEditTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 5,
            minLines: 3,
            maxLength: _maxLength,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
              hintText: s.shareEditHint,
              hintStyle:
                  const TextStyle(color: AppColors.textHint, fontSize: 14),
              counterText: '$_charCount/$_maxLength',
              counterStyle: TextStyle(
                color: _charCount >= _maxLength
                    ? Colors.redAccent
                    : AppColors.textHint,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.share, color: Colors.white),
              label: Text(
                s.share,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
