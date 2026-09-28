
import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

class FAProgressBar extends StatefulWidget {
  const FAProgressBar({
    super.key,
    this.currentValue = 0,
    this.maxValue = 100,
    this.size = 12,
    this.animatedDuration = const Duration(milliseconds: 300),
    this.direction = Axis.horizontal,
    this.verticalDirection = VerticalDirection.down,
    this.borderRadius = 12,
    this.backgroundColor = const Color(0x00FFFFFF),
    this.progressColor = const Color(0xFFFA7268),
    this.changeColorValue,
    this.changeProgressColor = const Color(0xFF5F4B8B),
    this.displayText,
  });

  final int currentValue;
  final int maxValue;
  final double size;
  final Duration animatedDuration;
  final Axis direction;
  final VerticalDirection verticalDirection;
  final double borderRadius;
  final Color backgroundColor;
  final Color progressColor;
  final int? changeColorValue;
  final Color changeProgressColor;
  final String? displayText;

  @override
  State<FAProgressBar> createState() => _FAProgressBarState();
}

class _FAProgressBarState extends State<FAProgressBar>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  double _currentBegin = 0;
  double _currentEnd = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animatedDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: _currentBegin,
      end: _currentEnd,
    ).animate(_controller);

    triggerAnimation();
  }

  @override
  void didUpdateWidget(covariant FAProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    triggerAnimation();
  }

  void triggerAnimation() {
    _currentBegin = _animation.value;

    _currentEnd = widget.maxValue == 0
        ? 0
        : (widget.currentValue / widget.maxValue).clamp(0.0, 1.0);

    _animation = Tween<double>(
      begin: _currentBegin,
      end: _currentEnd,
    ).animate(_controller);

    _controller
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedProgressBar(
      animation: _animation,
      widget: widget,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnimatedProgressBar extends AnimatedWidget {
  AnimatedProgressBar({
    super.key,
    required Animation<double> animation,
    required this.widget,
  }) : super(listenable: animation);

  final FAProgressBar widget;

  double transformValue(
    double x,
    double begin,
    double end,
    double before,
  ) {
    if (before == 0) return 0;

    double y = (end * x - (begin - before)) * (1 / before);

    return y < 0 ? 0 : (y > 1 ? 1 : y);
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;

    Color progressColor = widget.progressColor;

    if (widget.changeColorValue != null) {
      final colorTween = ColorTween(
        begin: widget.progressColor,
        end: widget.changeProgressColor,
      );

      progressColor =
          colorTween.transform(
            transformValue(
              animation.value,
              widget.changeColorValue!.toDouble(),
              widget.maxValue.toDouble(),
              5,
            ),
          ) ??
          widget.progressColor;
    }

    final List<Widget> progressWidgets = [];

    final progressWidget = Container(
      decoration: BoxDecoration(
        color: progressColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
    );

    progressWidgets.add(progressWidget);

    if (widget.displayText != null) {
      final textProgress = Container(
        alignment: widget.direction == Axis.horizontal
            ? const FractionalOffset(0.95, 0.5)
            : (widget.verticalDirection == VerticalDirection.up
                ? const FractionalOffset(0.5, 0.05)
                : const FractionalOffset(0.5, 0.95)),
        child: Text(
          '${(animation.value * widget.maxValue).toInt()}${widget.displayText}',
          softWrap: false,
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 8,
          ),
        ),
      );

      progressWidgets.add(textProgress);
    }

    final progressFlex = (animation.value * 100).toInt().clamp(0, 100);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: widget.direction == Axis.vertical ? widget.size : null,
        height: widget.direction == Axis.horizontal ? widget.size : null,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.progressColor,
            width: 0.2,
          ),
        ),
        child: Flex(
          direction: widget.direction,
          verticalDirection: widget.verticalDirection,
          children: [
            Expanded(
              flex: progressFlex,
              child: Stack(
                children: progressWidgets,
              ),
            ),
            Expanded(
              flex: 100 - progressFlex,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
