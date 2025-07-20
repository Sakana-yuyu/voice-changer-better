# Voice Changer Better - 实时语音变声器优化版

[English](README_en.md) | [日本語](README_ja.md) | 中文

## 项目简介

这是一个基于深度学习的实时语音变声器项目，支持多种语音变声模型，包括RVC、SoVitsSVC、DDSP-SVC等。本项目基于 [w-okada/voice-changer](https://github.com/w-okada/voice-changer) 进行UI界面优化，提供更好的用户体验。

## 原项目

本项目基于 [w-okada/voice-changer](https://github.com/w-okada/voice-changer) 开发，感谢原作者的优秀工作。

## UI界面优化内容

### 1. 整体布局优化
- **紧凑化设计**：减少了配置区域的间距和内边距，使界面更加紧凑
- **统一宽度**：所有配置子区域采用统一的弹性布局（`flex: 1`），确保视觉一致性
- **响应式布局**：优化了各个控件的最小宽度设置，提高了界面的响应性

### 2. 控制按钮优化
- **尺寸调整**：减小了按钮的字体大小、高度和内边距，使按钮更加紧凑
- **圆角优化**：统一了按钮的圆角半径，提供更现代的视觉效果
- **阴影效果**：优化了按钮的阴影效果，增强了视觉层次感
- **弹性布局**：按钮采用弹性布局，自动适应容器宽度

### 3. 滑块控件优化
- **间距调整**：减少了滑块控件之间的间距，提高空间利用率
- **字体优化**：调整了滑块标签和数值的字体大小，保持清晰可读
- **对齐方式**：优化了滑块控件的对齐方式，确保视觉整齐

### 4. 噪声控制区域优化
- **复选框布局**：优化了复选框容器的间距和字体大小
- **标签对齐**：改进了标签的对齐方式，提供更好的视觉效果

### 5. 字符区域控制优化
- **水平布局**：将增益控制移动到开始/停止/直通按钮的右侧
- **空间节省**：输入/输出增益滑块排列在同一行，节省垂直空间
- **视觉平衡**：通过CSS类 `.character-area-control-field-horizontal` 实现水平布局

## 技术实现

### 主要修改文件
1. **App.css** - 主要样式文件，包含所有UI优化的CSS规则
2. **101_CharacterArea.tsx** - 字符区域组件，实现了增益控制的布局调整

### 关键CSS类
- `.config-area` - 配置区域主容器
- `.config-sub-area` - 配置子区域容器
- `.config-sub-area-buttons` - 按钮容器
- `.config-sub-area-slider-control` - 滑块控件容器
- `.character-area-control-field-horizontal` - 字符区域水平布局

## 项目结构

```
├── client/demo/          # 前端演示应用
│   ├── src/
│   │   ├── css/         # 样式文件
│   │   └── components/  # React组件
│   └── public/          # 静态资源
├── server/              # 后端服务
├── docker/              # Docker配置
└── trainer/             # 模型训练相关
```

## 快速开始

### 前端开发
```bash
cd client/demo
npm install
npm start
```

### 后端服务
```bash
cd server
pip install -r requirements.txt
python MMVCServerSIO.py
```

## 特性

- 🎵 支持多种语音变声模型
- 🔄 实时语音处理
- 🎛️ 直观的用户界面
- 📱 响应式设计
- ⚡ 优化的性能
- 🎨 现代化的UI设计

## 许可证

本项目遵循原项目的许可证条款。详见 LICENSE 文件。

## 更新日志

### v1.0.0 (UI优化版)
- 完成整体UI界面的紧凑化设计
- 优化控制按钮和滑块控件的视觉效果
- 实现字符区域控制的水平布局
- 提升用户界面的整体一致性和美观度
