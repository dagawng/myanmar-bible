import 'package:flutter/material.dart';

/// Custom MarqueeText widget that automatically animates horizontal scrolling
/// when the text length exceeds the parent container width.
class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Duration velocity;
  final Duration pauseDuration;

  const MarqueeText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.velocity = const Duration(seconds: 6),
    this.pauseDuration = const Duration(seconds: 2),
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  late final ScrollController _scrollController;
  bool _isOverflowing = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _isAnimating = false;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    }
  }

  void _checkOverflowAndAnimate(double maxWidth) {
    final textStyle = widget.style ?? DefaultTextStyle.of(context).style;
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);

    final isOverflowing = textPainter.width > maxWidth;

    if (isOverflowing != _isOverflowing) {
      if (mounted) {
        setState(() {
          _isOverflowing = isOverflowing;
        });
      }
    }

    if (isOverflowing && !_isAnimating) {
      _startMarqueeAnimation(textPainter.width - maxWidth);
    }
  }

  void _startMarqueeAnimation(double overflowWidth) async {
    if (!mounted) return;
    _isAnimating = true;

    while (mounted && _isOverflowing) {
      await Future.delayed(widget.pauseDuration);
      if (!mounted || !_scrollController.hasClients) break;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final targetScroll = maxScroll > 0 ? maxScroll : overflowWidth;

      if (targetScroll <= 0) break;

      await _scrollController.animateTo(
        targetScroll,
        duration: widget.velocity,
        curve: Curves.easeInOut,
      );

      await Future.delayed(widget.pauseDuration);
      if (!mounted || !_scrollController.hasClients) break;

      await _scrollController.animateTo(
        0.0,
        duration: widget.velocity,
        curve: Curves.easeInOut,
      );
    }
    _isAnimating = false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkOverflowAndAnimate(constraints.maxWidth);
          }
        });

        if (!_isOverflowing) {
          return Text(
            widget.text,
            style: widget.style,
            textAlign: widget.textAlign,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
          ),
        );
      },
    );
  }
}
