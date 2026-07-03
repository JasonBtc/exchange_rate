import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/converter_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/currency_meta.dart';
import 'widgets/currency_picker.dart';

class ConverterPage extends StatelessWidget {
  const ConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ConverterController>();
    final settings = Get.find<SettingsController>();
    final amountCtrl = TextEditingController(
        text: c.amount.value == 0 ? '' : c.amount.value.toString());

    return Scaffold(
      appBar: AppBar(title: const Text('实时换算')),
      body: RefreshIndicator(
        onRefresh: () => c.load(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Obx(() {
              final baseCur = currencyOf(c.base.value);
              final targetCur = currencyOf(c.target.value);
              final dec = settings.decimals.value;
              return Card(
                color: const Color(0xFF1B1E27),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('输入金额',
                          style: TextStyle(color: Colors.white70)),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: amountCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                              onChanged: c.setAmount,
                            ),
                          ),
                          _chip(context, '${baseCur.flag} ${baseCur.code}',
                              () async {
                            final r = await showCurrencyPicker(context,
                                selected: c.base.value);
                            if (r != null) c.setBase(r);
                          }),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 32),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('换算为 ${targetCur.code}',
                                  style: const TextStyle(
                                      color: Colors.white70)),
                              Text(
                                c.result.toStringAsFixed(dec),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          _chip(context,
                              '${targetCur.flag} ${targetCur.code}',
                              () async {
                            final r = await showCurrencyPicker(context,
                                selected: c.target.value);
                            if (r != null) c.setTarget(r);
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Center(
              child: FilledButton.tonalIcon(
                onPressed: c.swap,
                icon: const Icon(Icons.swap_vert),
                label: const Text('交换币种'),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => c.error.value == null
                ? const SizedBox.shrink()
                : Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('数据加载失败：${c.error.value}',
                          style: TextStyle(color: Colors.red.shade700)),
                    ),
                  )),
            Obx(() {
              final r = c.unitRate;
              return Card(
                child: ListTile(
                  title: Text(
                      '1 ${c.base.value} ≈ ${r.toStringAsFixed(4)} ${c.target.value}'),
                  subtitle: Text(c.table.value == null
                      ? '加载中…'
                      : '更新时间 ${c.table.value!.updatedAt}'),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.white24,
      onPressed: onTap,
    );
  }
}
