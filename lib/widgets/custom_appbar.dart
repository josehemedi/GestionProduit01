import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar({
  required String title,
  Widget? leading,
  bool showBackButton = false,
}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    centerTitle: true,
    backgroundColor: Colors.blue,
    elevation: 4,
    leading: leading,
    automaticallyImplyLeading: showBackButton,
    iconTheme: const IconThemeData(color: Colors.white),
  );
}
