# 测试说明

本文档说明 Lumina 鸿蒙应用的测试用例和测试方法。

## 测试框架

项目使用 HarmonyOS 官方测试框架 **@ohos/hypium** 进行单元测试和集成测试。

## 测试结构

```
entry/src/ohosTest/
├── ets/
│   └── test/
│       ├── Ability.test.ets          # 应用能力测试
│       ├── ApiClient.test.ets        # API 客户端测试
│       ├── AuthService.test.ets      # 认证服务测试
│       ├── ImageService.test.ets     # 图片服务测试
│       ├── UserService.test.ets      # 用户服务测试
│       ├── AIService.test.ets        # AI 服务测试
│       ├── ApiConnection.test.ets    # API 连接测试
│       └── List.test.ets            # 测试套件入口
└── module.json5                      # 测试模块配置
```

## 运行测试

### 在 DevEco Studio 中运行

1. 打开项目
2. 右键点击测试文件或测试目录
3. 选择 "Run Tests" 或 "Debug Tests"

### 使用命令行

```bash
# 运行所有测试
hvigorw test

# 运行特定测试文件
hvigorw test --test-file ApiClient.test.ets
```

## 测试用例说明

### 1. ApiClient.test.ets

测试 API 客户端的基本功能：
- API 配置验证
- GET 请求
- POST 请求
- 错误处理

### 2. AuthService.test.ets

测试认证服务：
- 发送验证码
- 手机号登录
- 游客模式登录
- 微信登录
- Token 刷新

### 3. ImageService.test.ets

测试图片服务：
- 单图上传
- 批量上传
- 图片处理
- 获取图片信息

### 4. UserService.test.ets

测试用户服务：
- 获取用户信息
- 更新用户信息
- 获取用户作品列表

### 5. AIService.test.ets

测试 AI 服务：
- AI 问答
- AI 推荐

### 6. ApiConnection.test.ets

测试 API 连接：
- API 配置验证
- 服务器连接测试
- 网络超时处理

## 测试注意事项

### 1. 网络依赖

大部分测试用例需要网络连接和可用的 API 服务器。如果 API 服务器不可用，测试会跳过或显示警告。

### 2. 认证要求

某些测试需要有效的认证 token。在运行这些测试前，请确保：
- 已配置正确的 API 地址
- 已获取有效的认证 token（如果需要）

### 3. 测试数据

测试使用的数据（如手机号、图片路径等）可能需要根据实际情况调整。

### 4. Mock 支持

对于需要外部依赖的测试，可以使用 `@ohos/hamock` 进行 Mock。

## 编写新测试

### 基本结构

```typescript
import { hilog } from '@kit.PerformanceAnalysisKit';
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';

export default function myTest() {
  describe('MyTest', () => {
    beforeAll(() => {
      // 测试套件开始前的初始化
    });

    beforeEach(() => {
      // 每个测试用例前的准备工作
    });

    afterEach(() => {
      // 每个测试用例后的清理工作
    });

    afterAll(() => {
      // 测试套件结束后的清理
    });

    it('testSomething', 0, () => {
      // 测试用例
      expect(true).assertEqual(true);
    });
  });
}
```

### 异步测试

```typescript
it('testAsync', 0, async () => {
  const result = await someAsyncFunction();
  expect(result).assertNotUndefined();
});
```

### 断言方法

常用的断言方法：
- `expect(value).assertEqual(expected)` - 相等断言
- `expect(value).assertNotEqual(expected)` - 不等断言
- `expect(value).assertContain(substring)` - 包含断言
- `expect(value).assertNotUndefined()` - 非空断言
- `expect(value).assertAbove(threshold)` - 大于断言
- `expect(value).assertBelow(threshold)` - 小于断言

## 测试覆盖率

建议保持较高的测试覆盖率，特别是对于核心业务逻辑。

## 持续集成

可以将测试集成到 CI/CD 流程中，确保每次代码提交都运行测试。

## 参考文档

- [HarmonyOS 测试框架文档](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/ohos-test-framework-0000001263280421-V3)
- [hypium 使用指南](https://gitee.com/openharmony/testfwk_arkxtest)

