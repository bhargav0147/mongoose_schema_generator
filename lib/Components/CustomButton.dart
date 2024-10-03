// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String name; // Name of the button
  final VoidCallback onPressed; // Callback function for button press

  const CustomButton({
    super.key,
    required this.name,
    required this.onPressed,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed, // Use the onPressed callback from the widget
      child: Text(
        widget.name,
        style: TextStyle(letterSpacing: 0.5, fontSize: 16, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Set the background color to blue
      ),
    );
  }
}
