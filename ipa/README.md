# ORBIT iOS App

专业的卫星过境预测和实时跟踪 iOS 原生应用。

## 功能特性

- 🛰️ **卫星过境预测**: 计算未来卫星过境时间、仰角、方位角
- 📍 **实时卫星跟踪**: 使用设备传感器进行天线对准辅助
- 🌍 **多语言支持**: 中英双语界面
- 🧭 **罗盘辅助**: 实时显示卫星方位和仰角
- ⭐ **收藏功能**: 收藏常用卫星，批量计算过境信息
- 📅 **日历提醒**: 添加过境事件到系统日历
- 🌙 **夜间模式**: 自动适配深色/浅色主题

## 技术栈

- **语言**: Swift 5.0
- **UI 框架**: SwiftUI
- **最低支持**: iOS 15.0
- **架构**: MVVM + Combine
- **数据存储**: UserDefaults + JSON
- **定位服务**: CoreLocation
- **传感器**: CoreMotion

## 项目结构

```
ipa/
├── ORBIT.xcodeproj/          # Xcode 项目文件
├── ORBIT/                    # 源代码目录
│   ├── ORBITApp.swift        # 应用入口
│   ├── ContentView.swift     # 主界面
│   ├── TrackingView.swift    # 实时跟踪界面
│   ├── Satellite.swift       # 卫星数据模型
│   ├── SatelliteCalculator.swift  # 卫星轨道计算
│   ├── TLEData.swift         # TLE 数据管理
│   ├── PassPrediction.swift  # 过境预测
│   ├── LocationManager.swift # 位置管理
│   ├── LanguageManager.swift # 语言管理
│   ├── FavoritesManager.swift # 收藏管理
│   ├── Assets.xcassets/      # 资源文件
│   └── Preview Content/      # 预览资源
├── Info.plist                # 应用配置
└── README.md                 # 本文件
```

## 开发环境要求

- Xcode 15.0 或更高版本
- macOS 13.0 或更高版本
- iOS 15.0 SDK
- CocoaPods (可选)

## 本地构建

### 1. 克隆项目

```bash
git clone https://github.com/troilus/predict.git
cd predict/ipa
```

### 2. 打开项目

```bash
open ORBIT.xcodeproj
```

### 3. 选择目标设备

- 在 Xcode 顶部工具栏选择目标设备或模拟器

### 4. 运行项目

- 按 `Cmd + R` 或点击 Xcode 的运行按钮

### 5. 编译发布版本

```bash
# Archive
xcodebuild archive \
  -project ORBIT.xcodeproj \
  -scheme ORBIT \
  -configuration Release \
  -archivePath build/ORBIT.xcarchive \
  -sdk iphoneos

# Export IPA
xcodebuild -exportArchive \
  -archivePath build/ORBIT.xcarchive \
  -exportPath build/IPA \
  -exportOptionsPlist exportOptions.plist
```

## 配置说明

### 代码签名

发布版本需要配置代码签名：

1. 在 Apple Developer 账号创建 App ID
2. 创建开发和发布证书
3. 配置 Provisioning Profile
4. 在 Xcode 项目设置中选择签名团队

### 权限配置

应用需要以下权限：

- **位置权限**: 用于计算卫星过境时间
- **运动传感器**: 用于罗盘功能

权限描述在 `Info.plist` 中配置。

## GitHub Actions 自动构建

项目配置了 GitHub Actions 工作流，可以自动构建 iOS 应用。

### 触发构建

1. **自动触发**: 推送到 main/master 分支时自动构建
2. **手动触发**: 在 GitHub Actions 页面点击 "workflow_dispatch"

### 构建产物

- `ORBIT-Archive`: Xcode Archive (.xcarchive)
- `ORBIT-IPA`: iOS 应用包 (.ipa) - 仅手动触发时生成

### 配置 Secrets

为了导出 IPA，需要在 GitHub 仓库中配置以下 Secret：

- `EXPORT_OPTIONS_PLIST`: Export Options Plist 的 Base64 编码内容

示例 `exportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>uploadBitcode</key>
    <false/>
</dict>
</plist>
```

Base64 编码：

```bash
base64 -i exportOptions.plist | pbcopy
```

将复制的内容作为 Secret 的值。

## 核心功能实现

### 1. 卫星轨道计算

使用移植自 `satellite.js` 的 Swift 实现：

- TLE 解析
- SGP4/SDP4 轨道传播
- ECI/ECEF 坐标转换
- 观测者视角计算

### 2. 过境预测

- 遍历未来 N 天
- 计算卫星仰角
- 检测过境事件
- 计算最大仰角和方位

### 3. 实时跟踪

- 定时更新卫星位置
- 使用 CoreMotion 获取设备方向
- 罗盘显示卫星方位
- 计算距离和速度

### 4. 数据管理

- UserDefaults 存储用户偏好
- JSON 缓存 TLE 数据
- 收藏卫星列表

## 测试

### 单元测试

```bash
xcodebuild test \
  -project ORBIT.xcodeproj \
  -scheme ORBIT \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI 测试

使用 SwiftUI Preview 快速预览和测试 UI 组件。

## 已知问题

1. 需要配置代码签名才能在真机上运行
2. 某些传感器权限需要用户手动授权
3. 罗盘精度受设备磁场影响

## 未来计划

- [ ] 添加单元测试
- [ ] 支持更多卫星数据源
- [ ] 添加 3D 轨道可视化
- [ ] 支持 AR 对星辅助
- [ ] 添加离线模式
- [ ] 支持 WatchOS 扩展

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目采用开源许可证（详见 LICENSE 文件）。

## 联系方式

- 作者: bd8ckf
- 邮箱: bd8ckf@outlook.com
- 源代码: https://github.com/troilus/predict
- Web 版: https://sat.xanyi.eu.org/