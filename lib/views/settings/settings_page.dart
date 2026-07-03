import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SettingsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          Obx(() => SwitchListTile(
                title: const Text('深色主题'),
                subtitle: const Text('适合夜间查价'),
                value: c.isDark.value,
                onChanged: c.toggleTheme,
              )),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('换算精度'),
          ),
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 2, label: Text('2 位')),
                    ButtonSegment(value: 4, label: Text('4 位')),
                    ButtonSegment(value: 6, label: Text('6 位')),
                  ],
                  selected: {c.decimals.value},
                  onSelectionChanged: (s) => c.setDecimals(s.first),
                ),
              )),
          const Divider(),
          const ListTile(
            title: Text('数据来源'),
            subtitle: Text('open.er-api.com · 每日更新'),
          ),
          const AboutListTile(
            applicationName: '汇率换算',
            applicationVersion: '1.0.0',
          ),
        ],
      ),
    );
  }
}
