import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../core/app_colors.dart';
import '../converter/converter_page.dart';
import '../rates/rates_page.dart';
import '../settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  final _pages = const [
    ConverterPage(),
    RatesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      // Content fills the whole screen; the liquid-glass tab bar floats over
      // the bottom (matching the design's `.bottom-nav`). Pages add their own
      // bottom padding so their last item clears the bar.
      body: Stack(
        children: [
          IndexedStack(index: _index, children: _pages),
          Align(
            alignment: Alignment.bottomCenter,
            // GlassTabBar keeps its own floating margins (verticalPadding),
            // but not the device safe area, so guard the home indicator here.
            child: SafeArea(
              top: false,
              child: GlassTabBar.bottom(
                selectedIndex: _index,
                onTabSelected: (i) => setState(() => _index = i),
                // Soft accent wash for the indicator (matching the active
                // rows/chips elsewhere) so the accent-colored icon and label
                // stay readable, instead of a solid blue pill that hides them.
                indicatorColor: colors.accentSoft,
                selectedIconColor: colors.accent,
                selectedLabelColor: colors.accent,
                unselectedIconColor: colors.muted,
                unselectedLabelColor: colors.muted,
                tabs: [
                  GlassTab(icon: const Icon(Icons.swap_horiz), label: 'tab_convert'.tr),
                  GlassTab(icon: const Icon(Icons.list_alt), label: 'tab_rates'.tr),
                  GlassTab(icon: const Icon(Icons.settings), label: 'tab_settings'.tr),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
