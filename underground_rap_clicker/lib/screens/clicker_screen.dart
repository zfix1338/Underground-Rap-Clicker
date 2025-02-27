import 'package:flutter/material.dart';

class ClickerScreen extends StatelessWidget {
  final int listensCount;
  final VoidCallback onTap;

  const ClickerScreen({
    super.key,
    required this.listensCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Уменьшенный по высоте верхний счётчик
        Container(
          height: 60,
          color: Colors.white,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Прослушивания: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$listensCount',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}