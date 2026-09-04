import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// A single chat bubble. App messages sit left with a light background,
/// user messages right in the primary colour.
class ChatBubble extends StatelessWidget {
  final Widget child;
  final bool isUser;

  const ChatBubble({super.key, required this.child, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: width * 0.82),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: isUser ? Colors.white : Colors.black87,
              ),
          child: child,
        ),
      ),
    );
  }
}

/// Three dots shown while the pipeline is working. Prediction is fast
/// enough that this is usually a brief flash, which is the honest
/// impression to give - it is not a fake delay.
class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatBubble(
      child: SizedBox(
        width: 40,
        height: 14,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Dot(),
            _Dot(),
            _Dot(),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }
}
