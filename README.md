# exchange_rate · 汇率换算

[English](README.en.md) | 简体中文

基于实时汇率的货币换算 App，支持任意货币 ↔ 任意货币按当天汇率换算。内置实时换算、多币种行情、设置三个页面，UI 采用 Liquid Glass 玻璃质感底栏，支持中文 / English / 日本語 三语切换与亮/暗双主题。

> 本项目完全由 [Claude Code](https://claude.com/claude-code) 开发，UI 设计统一基于 Open Design 实现。

## 截图

| 实时换算 | 多币种行情 | 设置 |
| :---: | :---: | :---: |
| <img src="screenshot_en_us/exchange_home.png" width="240" /> | <img src="screenshot_en_us/exchange_rate.png" width="240" /> | <img src="screenshot_en_us/exchange_settings.png" width="240" /> |

## 功能

- **实时换算**：输入金额，任意基准币种换算为目标币种；支持一键交换方向（swap）、常用币种快速切换、下拉刷新。
- **多币种行情**：按当前基准（默认 CNY）展示各币种牌价，支持按代码 / 币种名称实时搜索过滤、下拉刷新。
- **多语言**：中文 / English / 日本語 三语实时切换，约 160 个币种均提供三语名称，界面文案与币种名同步本地化；语言偏好本地持久化。
- **设置**：语言切换、深色主题开关、换算精度（2 / 4 / 6 位）、自动刷新频率（手动 / 15 分钟 / 1 小时），偏好本地持久化。

## 架构（MVC）

```
lib/
├── main.dart              # GetMaterialApp 入口（翻译、locale、主题）
├── core/                  # 主题、路由、Dio 客户端、常量、币种元数据、i18n 翻译表
├── models/                # Currency 值对象、ExchangeRateTable（交叉汇率计算）
├── repositories/          # RateRepository：拉取 + 缓存 + 当天有效性 + 离线兜底
├── controllers/           # Converter / Rates / Settings 三个 GetxController
├── bindings/              # AppBinding：GetX 依赖注入
└── views/                 # home（底部导航壳）/ converter / rates / settings
```

- **Model**：`ExchangeRateTable` 以 USD 为基准存 `rates` map，交叉汇率 `rate(A→B) = usdRates[B] / usdRates[A]`，实现任意币种互换。
- **View**：GetX 响应式页面（`Obx`），对齐设计稿视觉规范（主色 `#2F6BFF`、大圆角卡片、数字等宽 tabular figures、Liquid Glass 底栏、亮/暗双主题）。
- **Controller**：`ConverterController` / `RatesController` / `SettingsController`，业务状态用 `.obs`。

## 国际化（i18n）

- 基于 GetX 内置的 `Translations` + `.tr`，翻译表见 `lib/core/app_translations.dart`，支持 `zh_CN` / `en_US` / `ja_JP`。
- 切换语言调用 `Get.updateLocale`，界面实时重建，无需重启。
- 币种名称随语言变化：`Currency` 模型带 `cnName` / `enName` / `jaName`，通过 `nameFor(localeKey)` 取当前语言名称，缺失时优雅回退。

## 数据源

- 接口：`https://open.er-api.com/v6/latest/USD`（免 API Key，返回以 USD 为基准的 `rates` 与 `time_last_update_unix`）。
- **按当天汇率**：缓存命中当天数据时直接复用，跨天或强制刷新时重新拉取。
- **离线兜底**：网络失败且存在缓存时，回退到最近一次成功拉取的数据。

## 技术栈

- Flutter 3.11+ / Dart 3
- [GetX](https://pub.dev/packages/get) — 状态管理 + 路由 + 依赖注入 + 国际化
- [Dio](https://pub.dev/packages/dio) — 网络请求（封装在 `ApiClient`）
- [get_storage](https://pub.dev/packages/get_storage) — 本地缓存与偏好持久化
- [country_flags](https://pub.dev/packages/country_flags) — 币种国旗图标
- [liquid_glass_widgets](https://pub.dev/packages/liquid_glass_widgets) — 玻璃质感底部导航栏
- [intl](https://pub.dev/packages/intl) — 数字/日期格式化

## 运行

本项目使用 [fvm](https://fvm.app/) 管理 Flutter 版本，命令需加 `fvm` 前缀：

```bash
fvm flutter pub get      # 安装依赖
fvm flutter run          # 运行到设备/模拟器
fvm flutter test         # 运行全部测试
fvm flutter analyze      # 静态检查
```

> 未使用 fvm 时，去掉 `fvm` 前缀直接执行 `flutter ...` 即可。

## 测试

单元测试覆盖交叉汇率计算、Repository 缓存/离线策略、三个 Controller 业务逻辑；widget 测试覆盖四个页面的关键交互与多语言渲染。

## 开源许可

[MIT](LICENSE)
