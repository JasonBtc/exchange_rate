import 'package:flutter/material.dart';
import '../converter/converter_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  // Task 14/15 完成后再补 rates/settings 页面
  final _pages = const [
    ConverterPage(),
    Center(child: Text('行情')),
    Center(child: Text('设置')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.swap_horiz), label: '换算'),
          NavigationDestination(
              icon: Icon(Icons.list_alt), label: '行情'),
          NavigationDestination(
              icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
