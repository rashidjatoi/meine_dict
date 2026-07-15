import 'package:flutter/material.dart';

import '../services/tts_service.dart';

enum PronounceButtonStyle { icon, filled }

class PronounceButton extends StatefulWidget {
  const PronounceButton({
    super.key,
    required this.text,
    this.style = PronounceButtonStyle.icon,
    this.label = 'Listen',
    this.iconSize,
    this.tooltip = 'Play pronunciation',
  });

  final String text;
  final PronounceButtonStyle style;
  final String label;
  final double? iconSize;
  final String tooltip;

  @override
  State<PronounceButton> createState() => _PronounceButtonState();
}

class _PronounceButtonState extends State<PronounceButton> {
  bool _isSpeaking = false;

  Future<void> _speak() async {
    if (_isSpeaking) {
      await TtsService.instance.stop();
      if (mounted) setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);
    try {
      await TtsService.instance.speakGerman(widget.text);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pronunciation is not available on this device.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.style == PronounceButtonStyle.filled) {
      return FilledButton.tonalIcon(
        onPressed: _speak,
        icon: Icon(_isSpeaking ? Icons.stop_circle : Icons.volume_up),
        label: Text(_isSpeaking ? 'Stop' : widget.label),
      );
    }

    return IconButton(
      onPressed: _speak,
      tooltip: widget.tooltip,
      icon: _isSpeaking
          ? SizedBox(
              width: widget.iconSize ?? 24,
              height: widget.iconSize ?? 24,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.volume_up, size: widget.iconSize),
    );
  }
}
