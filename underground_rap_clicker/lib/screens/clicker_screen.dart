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
        // Top portion of the screen with listens count
        Container(
          height: 100,
          color: Colors.white,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Прослушивания: ', // Display 'Прослушивания'
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$listensCount',    // Display the listens count
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Invisible tapping zone (no visible UI)
        Expanded(
          child: GestureDetector(
            onTap: onTap, // Tapping will call 'onTap' to increment the counter
            child: Container(
              color: Colors.transparent, // Invisible zone
            ),
          ),
        ),
      ],
    );
  }
}