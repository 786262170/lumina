# Lumina AI 鸿蒙应用

Lumina AI 图片处理应用前端，基于 HarmonyOS ArkTS 实现。

## 功能特性

- 用户认证与授权（手机号、微信、游客模式）
- AI问答与推荐
- 图片上传与处理（单图/批量）
- 作品管理
- 订阅与支付
- 场景配置管理

## 技术栈

- HarmonyOS API 9+
- ArkTS
- DevEco Studio
- HTTP 网络请求
- 本地存储

## 快速开始

### 1. 环境要求

- DevEco Studio 4.0 或更高版本
- HarmonyOS SDK API 9 或更高版本
- Node.js 16.9.0 或更高版本

### 2. 安装依赖

```bash
# 安装 npm 依赖
npm install

# 或使用 ohpm（推荐）
ohpm install
```

### 3. 配置 API 地址

编辑 `entry/src/main/ets/common/services/ApiClient.ets`，修改 API 基础地址：

```typescript
export class ApiConfig {
  // 开发/测试环境
  static readonly DEV_BASE_URL = 'http://your-api-server:8000/v1';
  
  // 生产环境
  static readonly PROD_BASE_URL = 'https://api.lumina.ai/v1';
  
  // 当前使用的Base URL
  static readonly BASE_URL = ApiConfig.DEV_BASE_URL;
}
```

### 4. 运行项目

1. 使用 DevEco Studio 打开项目
2. 连接 HarmonyOS 设备或启动模拟器
3. 点击运行按钮或使用快捷键运行

### 5. 构建发布版本

```bash
# 构建 HAP 包
hvigorw assembleHap

# 或使用 DevEco Studio 的构建功能
```

## 项目结构

```
lumina/
├── entry/                      # 应用主模块
│   ├── src/
│   │   ├── main/
│   │   │   ├── ets/
│   │   │   │   ├── common/     # 公共模块
│   │   │   │   │   ├── components/  # 组件
│   │   │   │   │   ├── services/    # 服务层
│   │   │   │   │   │   ├── ApiClient.ets      # API 客户端
│   │   │   │   │   │   ├── AuthService.ets    # 认证服务
│   │   │   │   │   │   ├── ImageService.ets   # 图片服务
│   │   │   │   │   │   ├── AIService.ets      # AI 服务
│   │   │   │   │   │   └── ...
│   │   │   │   │   ├── types/       # 类型定义
│   │   │   │   │   └── utils/       # 工具函数
│   │   │   │   ├── pages/      # 页面
│   │   │   │   │   ├── Index.ets
│   │   │   │   │   ├── Login.ets
│   │   │   │   │   ├── Workbench.ets
│   │   │   │   │   └── ...
│   │   │   │   └── entryability/  # 应用入口
│   │   │   └── resources/     # 资源文件
│   │   └── ohosTest/         # 测试代码
│   │       └── ets/
│   │           └── test/     # 测试用例
│   └── build-profile.json5
├── oh-package.json5          # 依赖配置
└── README.md
```

## 开发

### 代码规范

- 使用 TypeScript/ArkTS 严格模式
- 遵循 HarmonyOS 开发规范
- 组件命名使用 PascalCase
- 函数和变量使用 camelCase

### 测试

运行测试用例：

```bash
# 在 DevEco Studio 中运行测试
# 或使用命令行
hvigorw test
```

测试用例位于 `entry/src/ohosTest/ets/test/` 目录。

### 调试

1. 使用 DevEco Studio 的调试功能
2. 查看日志输出
3. 使用网络抓包工具检查 API 请求

## API 集成

应用通过 HTTP 请求与后端 API 通信。API 文档地址：

- **开发环境**: http://8.140.227.147:8000/docs
- **生产环境**: https://api.lumina.ai/docs

主要 API 端点：

- `/v1/auth/*` - 认证相关
- `/v1/user/*` - 用户信息
- `/v1/images/*` - 图片处理
- `/v1/ai/*` - AI 服务
- `/v1/works/*` - 作品管理
- `/v1/scenes/*` - 场景配置
- `/v1/subscription/*` - 订阅管理

## 权限说明

应用需要以下权限：

- `ohos.permission.INTERNET` - 网络访问
- `ohos.permission.READ_IMAGEVIDEO` - 读取图片和视频

权限配置在 `entry/src/main/module.json5` 中。

## 构建配置

### 签名配置

1. 在 DevEco Studio 中配置签名信息
2. 或使用命令行工具配置签名

### 打包配置

编辑 `entry/build-profile.json5` 配置构建选项。

## 常见问题

### 1. 网络请求失败

- 检查 API 地址配置是否正确
- 确认设备网络连接正常
- 检查后端服务是否运行

### 2. 图片上传失败

- 检查文件大小限制
- 确认权限配置正确
- 检查网络连接

### 3. 认证失败

- 检查 Token 是否过期
- 确认 API 地址配置正确
- 查看后端日志

## 许可证

MIT

