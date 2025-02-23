import 'package:flutter/material.dart';

class UpgradesScreen extends StatelessWidget {
  const UpgradesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: const Text(
        'Upgrades Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}