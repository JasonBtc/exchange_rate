import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/rates_controller.dart';

class RatesPage extends StatelessWidget {
  const RatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RatesController>();
    return Scaffold(
      appBar: AppBar(title: const Text('行情')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '搜索币种名称或代码',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => c.search.value = v,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => c.load(forceRefresh: true),
              child: Obx(() {
                final rows = c.rows;
                if (c.isLoading.value && rows.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (rows.isEmpty) {
                  return ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('没有匹配的币种')),
                    ],
                  );
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final row = rows[i];
                    return ListTile(
                      leading: Text(row.currency.flag,
                          style: const TextStyle(fontSize: 26)),
                      title: Text(
                          '${row.currency.cnName} ${row.currency.code}'),
                      subtitle: Text(
                          '1 ${row.currency.code} ≈ ${row.rate.toStringAsFixed(4)} ${c.quote.value}'),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
