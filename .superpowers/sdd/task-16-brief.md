### Task 16: 端到端联调与全量验证

**Files:**
- 可能微调：`exchange_rate/lib/views/home/home_page.dart`

**Interfaces:**
- Consumes: 全部前序 Task

- [ ] **Step 1: 全量静态检查**

Run: `cd exchange_rate && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: 全量测试**

Run: `cd exchange_rate && flutter test`
Expected: All tests passed!（models / repositories / controllers / views 全绿）

- [ ] **Step 3: 真机/模拟器冒烟运行**

Run: `cd exchange_rate && flutter run`
手动核对：
1. 首页显示今日汇率，输入金额实时换算，切换/交换币种正确；
2. 下拉刷新可强制更新；
3. 行情页搜索过滤正常；
4. 设置页切换深色主题即时生效、精度改变影响首页结果小数位；
5. 断网启动仍能显示上次缓存（离线兜底）。

- [ ] **Step 4: Commit**

```bash
cd exchange_rate && git add -A && git commit -m "chore: end-to-end integration verification"
```

---

## Self-Review

**1. Spec coverage**
- 任意货币↔任意货币换算 → Task 4（交叉汇率）+ Task 7（swap/setBase/setTarget）✅
- 按当天时间汇率 → Task 6（`isFromToday` 缓存有效性 + 强制刷新）✅
- 三个设计页面（换算/行情/设置）→ Task 13/14/15 ✅
- 底部导航 → Task 10 ✅
- MVC 分层 → models / repositories / controllers / views 目录 ✅
- GetX → 状态管理(Task 7-9)、路由/DI(Task 12) ✅
- Dio → Task 3 ✅
- 免 Key 数据源 open.er-api.com → Task 3/5 ✅
- 设计 token（配色/圆角）→ Task 11 ✅
- 离线缓存、深色主题、精度 → Task 6/9/15 ✅

**2. Placeholder scan**：无 TBD/TODO；所有 code step 均含完整代码。Task 10/13 的占位页是「有意的渐进式接线」，并在 Task 13-15 明确替换步骤，非占位符缺陷。

**3. Type consistency**
- `RateStorage.read/write` 签名在 Task 5 定义，Task 12 `GetStorageAdapter` 一致实现 ✅
- `RateRepository({required api, required storage})` 在 Task 5-7-8-12 一致 ✅
- `ExchangeRateTable.convert/rate/isFromToday/fromJson/toJson` 定义(Task 4)与调用(Task 6/7/8)一致 ✅
- `ConverterController` 字段 `base/target/amount/result/unitRate/swap/setAmount/setBase/setTarget`(Task 7)与 View(Task 13)一致 ✅
- `RatesController.rows/RateRow/quote/search`(Task 8)与 View(Task 14)一致 ✅
- `SettingsController.isDark/decimals/toggleTheme/setDecimals`(Task 9)与 View(Task 15)一致 ✅

未发现签名不一致或未定义引用。
