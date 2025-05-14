import 'package:flutter/material.dart';

AlertDialog createOKAlert(String title, String content, BuildContext context) => AlertDialog(
  title: Text(title),
  content: Text(content),
  actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("ОК"))],
);