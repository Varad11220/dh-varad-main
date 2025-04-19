import 'package:flutter/material.dart';
import 'navdrawer.dart'; // Import your navigation drawer

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget? appBarActions;
  final Widget body;

  const BaseScaffold({
    super.key,
    required this.title,
    this.appBarActions,
    required this.body,
    FloatingActionButton? floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: appBarActions != null ? [appBarActions!] : [],
      ),
      drawer: const SideNavigationBar(), // Navigation drawer
      body: body,
    );
  }
}
