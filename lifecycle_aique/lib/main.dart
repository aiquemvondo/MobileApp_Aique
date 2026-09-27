import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: LifecyclePage()));

class LifecyclePage extends StatefulWidget {
  const LifecyclePage({super.key});
  @override
  State<LifecyclePage> createState() => _LifecyclePageState();
}

class _LifecyclePageState extends State<LifecyclePage>
    with WidgetsBindingObserver {
  final List<String> _log = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final time = DateTime.now().toString().substring(11, 19);
    print('[$time] App state changed to: $state');
    setState(() => _log.add('[$time] $state'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Lifecycle - Aique')),
      body: ListView(
        children: _log.map((e) => ListTile(title: Text(e))).toList(),
      ),
    );
  }
}