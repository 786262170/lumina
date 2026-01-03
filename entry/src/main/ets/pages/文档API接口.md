# Lumina AI API 接口文档

## 📋 文档说明

本文档详细说明了 Lumina AI 后端 API 的所有接口，用于 HarmonyOS 前端项目对接。

**后端项目路径**: `F:\beijiao\HarmonyOS\lum\lumina-api`  
**API 版本**: v1  
**基础路径**: `/v1`  
**认证方式**: Bearer Token (JWT)

---

## 🔐 认证说明

### Token 认证

所有需要认证的接口都需要在请求头中添加 `Authorization` 字段：

```
Authorization: Bearer {token}
```

### Token 获取

通过登录接口获取 `token` 和 `refreshToken`：
- `token`: 访问令牌，有效期 2 小时（7200 秒）
- `refreshToken`: 刷新令牌，有效期 30 天

### Token 刷新

当 `token` 过期时，可以使用 `refreshToken` 刷新（当前版本暂未实现刷新接口，需要重新登录）。

---

## 🌐 API 基础信息

### 开发/测试环境
- **Base URL**: `http://8.140.227.147:8000`
- **API 文档**: `http://8.140.227.147:8000/docs`
- **ReDoc**: `http://8.140.227.147:8000/redoc`

### 生产环境
- **Base URL**: `https://api.lumina.ai` (根据实际配置)
- **API 文档**: `https://api.lumina.ai/docs`

### 通用响应格式

#### 成功响应
```json
{
  "success": true,
  "message": "操作成功",
  "data": { ... }
}
```

#### 错误响应
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述",
    "details": { ... }
  }
}
```

---

## 📚 API 接口列表

### 1. 认证相关 (Authentication)

#### 1.1 发送验证码

**接口**: `POST /v1/auth/send-code`

**描述**: 向指定手机号发送验证码

**请求参数**:
```json
{
  "phoneNumber": "13812345678"
}
```

**参数说明**:
- `phoneNumber` (string, 必填): 手机号码，11位，以1开头

**响应示例**:
```json
{
  "success": true,
  "message": "验证码已发送",
  "expiresIn": 300
}
```

**响应字段**:
- `success` (boolean): 是否成功
- `message` (string): 提示信息
- `expiresIn` (number): 验证码有效期（秒），默认 300 秒

---

#### 1.2 手机号登录

**接口**: `POST /v1/auth/login`

**描述**: 使用手机号和验证码登录

**请求参数**:
```json
{
  "phoneNumber": "13812345678",
  "verificationCode": "123456"
}
```

**参数说明**:
- `phoneNumber` (string, 必填): 手机号码
- `verificationCode` (string, 必填): 6位验证码

**响应示例**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user_123456",
    "phoneNumber": "138****5678",
    "nickname": "创作者",
    "avatar": "https://cdn.lumina.ai/avatars/user_123456.jpg",
    "isPro": true,
    "membershipType": "annual",
    "membershipExpiry": "2025-01-28T00:00:00Z",
    "createdAt": "2024-01-01T00:00:00Z"
  },
  "isNewUser": false,
  "expiresIn": 7200
}
```

**响应字段**:
- `token` (string): JWT 访问令牌
- `refreshToken` (string): 刷新令牌
- `user` (object): 用户信息
  - `id` (string): 用户ID
  - `phoneNumber` (string): 手机号（脱敏）
  - `nickname` (string): 昵称
  - `avatar` (string): 头像URL
  - `isPro` (boolean): 是否为专业版会员
  - `membershipType` (string): 会员类型（"free" | "monthly" | "annual"）
  - `membershipExpiry` (string): 会员到期时间（ISO 8601）
  - `createdAt` (string): 创建时间（ISO 8601）
- `isNewUser` (boolean): 是否为新用户
- `expiresIn` (number): Token 过期时间（秒）

---

#### 1.3 微信登录

**接口**: `POST /v1/auth/wechat-login`

**描述**: 使用微信授权码登录

**请求参数**:
```json
{
  "code": "081abc123def456"
}
```

**参数说明**:
- `code` (string, 必填): 微信授权码

**响应格式**: 同手机号登录

---

#### 1.4 游客模式

**接口**: `POST /v1/auth/guest`

**描述**: 创建游客账号（无需认证）

**请求参数**: 无

**响应格式**: 同手机号登录

---

#### 1.5 登出

**接口**: `POST /v1/auth/logout`

**描述**: 登出，将当前 token 加入黑名单

**请求头**: 
```
Authorization: Bearer {token}
```

**响应示例**:
```json
{
  "success": true,
  "message": "登出成功"
}
```

---

### 2. 用户相关 (User)

#### 2.1 获取用户信息

**接口**: `GET /v1/user/profile`

**描述**: 获取当前登录用户的详细信息

**请求头**: 
```
Authorization: Bearer {token}
```

**响应示例**:
```json
{
  "id": "user_123456",
  "phoneNumber": "138****5678",
  "nickname": "创作者",
  "avatar": "https://cdn.lumina.ai/avatars/user_123456.jpg",
  "isPro": true,
  "membershipType": "annual",
  "membershipExpiry": "2025-01-28T00:00:00Z",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

---

#### 2.2 更新用户信息

**接口**: `PUT /v1/user/profile`

**描述**: 更新用户昵称和头像

**请求头**: 
```
Authorization: Bearer {token}
```

**请求参数**:
```json
{
  "nickname": "新昵称",
  "avatar": "https://cdn.lumina.ai/avatars/new_avatar.jpg"
}
```

**参数说明**:
- `nickname` (string, 可选): 昵称，1-20 个字符
- `avatar` (string, 可选): 头像URL

**响应格式**: 同获取用户信息

---

#### 2.3 获取用户统计信息

**接口**: `GET /v1/user/stats`

**描述**: 获取用户的统计数据

**请求头**: 
```
Authorization: Bearer {token}
```

**响应示例**:
```json
{
  "processedCount": 1234,
  "remainingQuota": 58,
  "dailyQuota": -1,
  "membershipDaysLeft": 28,
  "storageUsed": 2.3,
  "storageTotal": 5.0
}
```

**响应字段**:
- `processedCount` (number): 已处理图片数量
- `remainingQuota` (number): 剩余配额（-1 表示无限）
- `dailyQuota` (number): 每日配额（-1 表示无限）
- `membershipDaysLeft` (number): 会员剩余天数
- `storageUsed` (number): 已使用存储空间（GB）
- `storageTotal` (number): 总存储空间（GB，-1 表示无限）

---

### 3. 图片相关 (Images)

#### 3.1 上传图片

**接口**: `POST /v1/images/upload`

**描述**: 上传一张或多张图片

**请求头**: 
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**请求参数** (Form Data):
- `files` (File[], 必填): 图片文件列表（支持多文件）
- `sceneType` (string, 可选): 场景类型（"taobao" | "douyin" | "xiaohongshu" | "amazon" | "custom"）

**响应示例**:
```json
{
  "images": [
    {
      "id": "img_abc123",
      "filename": "IMG_2024.jpg",
      "url": "https://cdn.lumina.ai/uploads/img_abc123.jpg",
      "thumbnail": "https://cdn.lumina.ai/uploads/thumb_img_abc123.jpg",
      "width": 1920,
      "height": 1080,
      "size": 2048000,
      "format": "jpg",
      "uploadedAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```

**响应字段**:
- `images` (array): 上传的图片列表
  - `id` (string): 图片ID
  - `filename` (string): 文件名
  - `url` (string): 图片URL
  - `thumbnail` (string): 缩略图URL
  - `width` (number): 图片宽度
  - `height` (number): 图片高度
  - `size` (number): 文件大小（字节）
  - `format` (string): 图片格式（"jpg" | "png" | "webp"）
  - `uploadedAt` (string): 上传时间（ISO 8601）

---

#### 3.2 处理单张图片

**接口**: `POST /v1/images/process`

**描述**: 对单张图片进行处理（抠图、背景、光效、滤镜、尺寸调整等）

**请求头**: 
```
Authorization: Bearer {token}
```

**请求参数**:
```json
{
  "imageId": "img_abc123",
  "operations": [
    {
      "type": "cutout",
      "params": {}
    },
    {
      "type": "background",
      "params": {
        "backgroundColor": "#FFFFFF",
        "backgroundTemplateId": "white"
      }
    },
    {
      "type": "lighting",
      "params": {
        "brightness": 1.2,
        "contrast": 1.1
      }
    }
  ],
  "outputSize": "2000x2000",
  "quality": 85,
  "edgeSmoothing": true,
  "sceneType": "taobao"
}
```

**参数说明**:
- `imageId` (string, 必填): 要处理的图片ID
- `operations` (array, 必填): 处理操作列表
  - `type` (string): 操作类型（"cutout" | "background" | "lighting" | "filter" | "resize"）
  - `params` (object): 操作参数（根据 type 不同而不同）
- `outputSize` (string, 可选): 输出尺寸，格式为 "宽x高"，如 "2000x2000"
- `quality` (number, 可选): 输出质量，60-100，默认 85
- `edgeSmoothing` (boolean, 可选): 是否启用边缘平滑，默认 true
- `sceneType` (string, 可选): 场景类型

**响应示例**:
```json
{
  "taskId": "task_xyz789",
  "status": "pending",
  "estimatedTime": 5
}
```

**响应字段**:
- `taskId` (string): 处理任务ID
- `status` (string): 任务状态（"pending" | "processing" | "completed" | "failed"）
- `estimatedTime` (number): 预计处理时间（秒）

---

#### 3.3 批量处理图片

**接口**: `POST /v1/images/batch-process`

**描述**: 批量处理多张图片（最多100张）

**请求头**: 
```
Authorization: Bearer {token}
```

**请求参数**:
```json
{
  "imageIds": ["img_abc123", "img_def456"],
  "operations": [
    {
      "type": "cutout",
      "params": {}
    },
    {
      "type": "background",
      "params": {
        "backgroundColor": "#FFFFFF"
      }
    }
  ],
  "outputSize": "2000x2000",
  "quality": 85,
  "edgeSmoothing": true,
  "sceneType": "taobao"
}
```

**参数说明**: 同单张图片处理，但 `imageIds` 为数组

**响应示例**:
```json
{
  "batchTaskId": "batch_task_xyz789",
  "tasks": [
    {
      "taskId": "task_001",
      "status": "pending",
      "estimatedTime": 5
    },
    {
      "taskId": "task_002",
      "status": "pending",
      "estimatedTime": 5
    }
  ],
  "totalCount": 2
}
```

---

#### 3.4 获取处理进度

**接口**: `GET /v1/images/process/{taskId}/status`

**描述**: 查询图片处理任务的进度

**请求头**: 
```
Authorization: Bearer {token}
```

**路径参数**:
- `taskId` (string): 任务ID

**响应示例**:
```json
{
  "taskId": "task_xyz789",
  "status": "processing",
  "progress": 65,
  "message": "正在处理中..."
}
```

**响应字段**:
- `taskId` (string): 任务ID
- `status` (string): 任务状态
- `progress` (number): 处理进度（0-100）
- `message` (string): 状态消息

---

#### 3.5 获取处理结果

**接口**: `GET /v1/images/process/{taskId}/result`

**描述**: 获取图片处理结果

**请求头**: 
```
Authorization: Bearer {token}
```

**路径参数**:
- `taskId` (string): 任务ID

**响应示例**:
```json
{
  "taskId": "task_xyz789",
  "status": "completed",
  "originalImage": {
    "id": "img_abc123",
    "url": "https://cdn.lumina.ai/uploads/img_abc123.jpg"
  },
  "processedImage": {
    "id": "processed_img_xyz789",
    "url": "https://cdn.lumina.ai/processed/processed_img_xyz789.jpg",
    "thumbnail": "https://cdn.lumina.ai/processed/thumb_processed_img_xyz789.jpg",
    "width": 2000,
    "height": 2000,
    "size": 1536000,
    "format": "jpg"
  },
  "operations": [
    {
      "type": "cutout",
      "params": {}
    }
  ],
  "processTime": 4.2
}
```

---

#### 3.6 分析图片

**接口**: `POST /v1/images/analyze`

**描述**: 使用 AI 分析图片（GLM-4.7v）

**请求头**: 
```
Authorization: Bearer {token}
```

**请求参数**:
```json
{
  "imageId": "img_abc123",
  "prompt": "请分析这张图片",
  "maxTokens": 500
}
```

**参数说明**:
- `imageId` (string, 必填): 图片ID
- `prompt` (string, 可选): 分析提示词
- `maxTokens` (number, 可选): 最大 token 数，默认 500

**响应示例**:
```json
{
  "imageId": "img_abc123",
  "description": "这是一张产品图片，展示了...",
  "tags": ["产品", "电商", "白底"],
  "mainSubject": "产品主体",
  "style": "简约",
  "qualityScore": 0.85,
  "suggestions": ["建议使用纯白背景", "可以调整亮度"]
}
```

---

#### 3.7 下载图片

**接口**: `GET /v1/images/{imageId}/download`

**描述**: 下载图片（支持指定质量和格式）

**请求头**: 
```
Authorization: Bearer {token}
```

**路径参数**:
- `imageId` (string): 图片ID

**查询参数**:
- `quality` (number, 可选): 图片质量，60-100，默认 85
- `format` (string, 可选): 图片格式（"jpg" | "png" | "webp"），默认 "jpg"

**响应**: 图片文件流

---

### 4. 作品相关 (Works)

#### 4.1 获取作品列表

**接口**: `GET /v1/works`

**描述**: 获取用户的作品列表（支持分页和分类筛选）

**请求头**: 
```
Authorization: Bearer {token}
```

**查询参数**:
- `page` (number, 可选): 页码，从 1 开始，默认 1
- `pageSize` (number, 可选): 每页数量，1-100，默认 20
- `category` (string, 可选): 分类筛选（"taobao" | "douyin" | "xiaohongshu" | "amazon" | "custom"）

**响应示例**:
```json
{
  "works": [
    {
      "id": "work_123456",
      "filename": "IMG_2024_processed.jpg",
      "thumbnail": "https://cdn.lumina.ai/works/thumb_work_123456.jpg",
      "category": "taobao",
      "size": 1536000,
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 100,
    "totalPages": 5
  },
  "totalStorage": 2457600000
}
```

**响应字段**:
- `works` (array): 作品列表
  - `id` (string): 作品ID
  - `filename` (string): 文件名
  - `thumbnail` (string): 缩略图URL
  - `category` (string): 分类
  - `size` (number): 文件大小（字节）
  - `createdAt` (string): 创建时间（ISO 8601）
- `pagination` (object): 分页信息
  - `page` (number): 当前页码
  - `pageSize` (number): 每页数量
  - `total` (number): 总数量
  - `totalPages` (number): 总页数
- `totalStorage` (number): 总存储使用量（字节）

---

#### 4.2 保存作品

**接口**: `POST /v1/works`

**描述**: 将处理后的图片保存为作品

**请求头**: 
```
Authorization: Bearer {token}
```

**请求参数**:
```json
{
  "processedImageId": "processed_img_xyz789",
  "filename": "IMG_2024_processed.jpg",
  "category": "taobao",
  "tags": ["产品图", "白底图"]
}
```

**参数说明**:
- `processedImageId` (string, 必填): 处理后的图片ID
- `filename` (string, 必填): 作品文件名
- `category` (string, 可选): 作品分类
- `tags` (array, 可选): 标签列表

**响应示例**:
```json
{
  "id": "work_123456",
  "filename": "IMG_2024_processed.jpg",
  "thumbnail": "https://cdn.lumina.ai/works/thumb_work_123456.jpg",
  "category": "taobao",
  "size": 1536000,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

---

#### 4.3 获取作品详情

**接口**: `GET /v1/works/{workId}`

**描述**: 获取作品的详细信息

**请求头**: 
```
Authorization: Bearer {token}
```

**路径参数**:
- `workId` (string): 作品ID

**响应示例**:
```json
{
  "id": "work_123456",
  "filename": "IMG_2024_processed.jpg",
  "thumbnail": "https://cdn.lumina.ai/works/thumb_work_123456.jpg",
  "category": "taobao",
  "size": 1536000,
  "createdAt": "2024-01-15T10:30:00Z",
  "imageUrl": "https://cdn.lumina.ai/works/work_123456.jpg",
  "beforeImage": {
    "id": "img_abc123",
    "url": "https://cdn.lumina.ai/uploads/img_abc123.jpg"
  },
  "afterImage": {
    "id": "processed_img_xyz789",
    "url": "https://cdn.lumina.ai/processed/processed_img_xyz789.jpg"
  },
  "tags": ["产品图", "白底图"],
  "operations": [
    {
      "type": "cutout",
      "params": {}
    }
  ]
}
```

---

#### 4.4 删除作品

**接口**: `DELETE /v1/works/{workId}`

**描述**: 删除指定作品

**请求头**: 
```
Authorization: Bearer {token}
```

**路径参数**:
- `workId` (string): 作品ID

**响应示例**:
```json
{
  "success": true,
  "message": "删除成功"
}
```

---

#### 4.5 批量删除作品

**接口**: `POST /v1/works/batch-delete`

**描述**: 批量删除作品

**请求头**: 
```
Authorization: Bearer {token}
```

**请求参数**:
```json
{
  "workIds": ["work_123456", "work_789012"]
}
```

**参数说明**:
- `workIds` (array, 必填): 作品ID列表，至少1个

**响应示例**:
```json
{
  "success": true,
  "message": "删除成功"
}
```

---

### 5. 场景相关 (Scenes)

#### 5.1 获取场景列表

**接口**: `GET /v1/scenes`

**描述**: 获取所有可用的场景配置（无需认证）

**响应示例**:
```json
{
  "scenes": [
    {
      "type": "taobao",
      "title": "淘宝白底图",
      "description": "自动生成纯白背景，符合淘宝平台规格",
      "presetSizes": ["2000x2000", "1600x1600", "1000x1000"],
      "defaultOperations": [
        {
          "type": "cutout",
          "params": {}
        },
        {
          "type": "background",
          "params": {
            "backgroundColor": "#FFFFFF"
          }
        }
      ]
    }
  ]
}
```

---

#### 5.2 获取场景详情

**接口**: `GET /v1/scenes/{sceneType}`

**描述**: 获取指定场景的详细信息（无需认证）

**路径参数**:
- `sceneType` (string): 场景类型（"taobao" | "douyin" | "xiaohongshu" | "amazon" | "custom"）

**响应示例**: 同场景列表中的单个场景对象

---

### 6. AI 相关 (AI)

#### 6.1 提交 AI 问答

**接口**: `POST /v1/ai/quiz`

**描述**: 提交 AI 问答答案（可选认证）

**请求参数**:
```json
{
  "answers": {
    "1": "clothing",
    "2": "taobao",
    "3": "minimal"
  }
}
```

**参数说明**:
- `answers` (object, 必填): 问答答案，key 为问题序号（1-based），value 为选项ID

**响应示例**:
```json
{
  "sessionId": "quiz_session_abc123",
  "message": "提交成功"
}
```

**响应字段**:
- `sessionId` (string): 问答会话ID，可用于获取推荐
- `message` (string): 提示信息

---

#### 6.2 获取 AI 推荐

**接口**: `GET /v1/ai/recommendations`

**描述**: 获取 AI 推荐方案（可选认证）

**查询参数**:
- `quizSessionId` (string, 可选): 问答会话ID（如果提供则基于问答结果，否则基于用户历史）

**响应示例**:
```json
{
  "primaryRecommendation": {
    "sceneType": "taobao",
    "sceneName": "电商主图",
    "matchPercentage": 98,
    "previewImage": "https://cdn.lumina.ai/previews/taobao.jpg",
    "description": "基于您的选择，这个场景最适合您的需求"
  },
  "alternatives": [
    {
      "sceneType": "douyin",
      "sceneName": "抖音商品图",
      "matchPercentage": 85,
      "previewImage": "https://cdn.lumina.ai/previews/douyin.jpg",
      "description": "适合社交媒体推广"
    }
  ],
  "recommendedFeatures": [
    {
      "id": "smart_cutout",
      "name": "智能抠图",
      "description": "AI精准识别主体，一键移除背景",
      "icon": "sparkles"
    }
  ]
}
```

---

### 7. 订阅相关 (Subscription)

#### 7.1 获取订阅计划

**接口**: `GET /v1/subscription/plans`

**描述**: 获取所有可用的订阅计划（无需认证）

**响应示例**:
```json
{
  "plans": [
    {
      "id": "monthly",
      "name": "月付会员",
      "price": 29,
      "period": "/月",
      "periodSubtext": null,
      "badge": null,
      "features": ["每日50次使用", "标准处理速度", "标准质量导出"],
      "highlighted": false
    },
    {
      "id": "annual",
      "name": "年度会员",
      "price": 299,
      "period": "/年",
      "periodSubtext": "(平均¥25/月)",
      "badge": {
        "text": "省30%",
        "color": "primary"
      },
      "features": ["每日无限使用", "极速处理", "高清导出"],
      "highlighted": true
    }
  ]
}
```

---

#### 7.2 获取当前订阅

**接口**: `GET /v1/subscription/current`

**描述**: 获取当前用户的订阅信息

**请求头**: 
```
Authorization: Bearer {token}
```

**响应示例**:
```json
{
  "planId": "annual",
  "planName": "年度会员",
  "startDate": "2024-01-01T00:00:00Z",
  "expiryDate": "2025-01-01T00:00:00Z",
  "isActive": true,
  "autoRenew": true
}
```

---

#### 7.3 创建订阅订单

**接口**: `POST /v1/subscription/create-order`

**描述**: 创建订阅订单

**请求头**: 
```
Authorization: Bearer {token}
```

**请求参数**:
```json
{
  "planId": "annual",
  "paymentMethod": "wechat"
}
```

**参数说明**:
- `planId` (string, 必填): 计划ID（"monthly" | "annual"）
- `paymentMethod` (string, 必填): 支付方式（"wechat" | "alipay"）

**响应示例**:
```json
{
  "orderId": "order_abc123",
  "amount": 299,
  "paymentInfo": {
    "qrCode": "https://api.lumina.ai/payment/qr/order_abc123",
    "paymentUrl": "weixin://wxpay/bizpayurl?pr=xxx"
  },
  "expiresAt": "2024-01-15T11:00:00Z"
}
```

---

#### 7.4 支付回调

**接口**: `POST /v1/subscription/payment-callback`

**描述**: 支付平台回调接口（由支付平台调用，前端无需直接调用）

---

### 8. 设置相关 (Settings)

#### 8.1 获取应用设置

**接口**: `GET /v1/settings`

**描述**: 获取用户的应用设置

**请求头**: 
```
Authorization: Bearer {token}
```

**响应示例**:
```json
{
  "notifications": true,
  "autoSave": true,
  "defaultQuality": 85,
  "defaultFormat": "jpg"
}
```

**响应字段**:
- `notifications` (boolean): 是否启用通知
- `autoSave` (boolean): 是否自动保存
- `defaultQuality` (number): 默认图片质量（60-100）
- `defaultFormat` (string): 默认图片格式（"jpg" | "png" | "webp"）

---

#### 8.2 更新应用设置

**接口**: `PUT /v1/settings`

**描述**: 更新用户的应用设置

**请求头**: 
```
Authorization: Bearer {token}
```

**请求参数**:
```json
{
  "notifications": false,
  "autoSave": true,
  "defaultQuality": 90,
  "defaultFormat": "png"
}
```

**参数说明**: 所有字段均为可选，只更新提供的字段

**响应格式**: 同获取应用设置

---

## 📝 数据模型说明

### 枚举类型

#### SceneType (场景类型)
- `taobao`: 淘宝白底图
- `douyin`: 抖音商品图
- `xiaohongshu`: 小红书封面
- `amazon`: 亚马逊产品图
- `custom`: 自定义制作

#### OperationType (操作类型)
- `cutout`: 智能抠图
- `background`: 背景处理
- `lighting`: 光效调整
- `filter`: 滤镜
- `resize`: 尺寸调整

#### TaskStatus (任务状态)
- `pending`: 等待处理
- `processing`: 处理中
- `completed`: 已完成
- `failed`: 处理失败

#### ImageFormat (图片格式)
- `jpg`: JPEG 格式
- `png`: PNG 格式
- `webp`: WebP 格式

#### MembershipType (会员类型)
- `free`: 免费用户
- `monthly`: 月付会员
- `annual`: 年付会员

#### PaymentMethod (支付方式)
- `wechat`: 微信支付
- `alipay`: 支付宝

---

## 🔧 HarmonyOS 集成示例

### 1. HTTP 请求封装

在 HarmonyOS 中，可以使用 `@ohos.net.http` 模块进行 HTTP 请求：

```typescript
import http from '@ohos.net.http';

// API 基础配置
const API_BASE_URL = 'http://8.140.227.147:8000/v1';
let accessToken: string = '';

// 发送 HTTP 请求
async function request(
  method: 'GET' | 'POST' | 'PUT' | 'DELETE',
  path: string,
  data?: any,
  needAuth: boolean = true
): Promise<any> {
  const httpRequest = http.createHttp();
  
  const url = `${API_BASE_URL}${path}`;
  const options: http.HttpRequestOptions = {
    method: method,
    header: {
      'Content-Type': 'application/json'
    },
    readTimeout: 30000,
    connectTimeout: 30000
  };

  // 添加认证头
  if (needAuth && accessToken) {
    options.header['Authorization'] = `Bearer ${accessToken}`;
  }

  // 添加请求体
  if (data && (method === 'POST' || method === 'PUT')) {
    options.extraData = JSON.stringify(data);
  }

  try {
    const response = await httpRequest.request(url, options);
    const result = JSON.parse(response.result.toString());
    
    if (response.responseCode === 200) {
      return result;
    } else {
      throw new Error(result.error?.message || '请求失败');
    }
  } catch (error) {
    console.error(`请求失败: ${error.message}`);
    throw error;
  } finally {
    httpRequest.destroy();
  }
}
```

### 2. 登录示例

```typescript
// 发送验证码
async function sendVerificationCode(phoneNumber: string): Promise<void> {
  await request('POST', '/auth/send-code', { phoneNumber }, false);
}

// 手机号登录
async function login(phoneNumber: string, verificationCode: string): Promise<LoginResponse> {
  const response = await request('POST', '/auth/login', {
    phoneNumber,
    verificationCode
  }, false);
  
  // 保存 token
  accessToken = response.token;
  
  return response;
}
```

### 3. 上传图片示例

```typescript
// 注意：HarmonyOS 中上传文件需要使用 FormData
import picker from '@kit.CoreFileKit';

async function uploadImage(imageUri: string, sceneType?: string): Promise<UploadedImage[]> {
  // 读取文件
  const file = await picker.getFile(imageUri);
  const fileData = await file.readArrayBuffer();
  
  // 构建 FormData（需要使用 @ohos.net.http 的 multipart 方式）
  // 这里简化示例，实际需要使用支持 multipart 的 HTTP 库
  
  const response = await request('POST', '/images/upload', {
    files: [fileData],
    sceneType
  });
  
  return response.images;
}
```

### 4. 处理图片示例

```typescript
async function processImage(
  imageId: string,
  operations: ImageOperation[],
  options?: {
    outputSize?: string;
    quality?: number;
    edgeSmoothing?: boolean;
    sceneType?: string;
  }
): Promise<ProcessTaskResponse> {
  return await request('POST', '/images/process', {
    imageId,
    operations,
    ...options
  });
}
```

### 5. 查询处理结果示例

```typescript
// 轮询查询处理结果
async function waitForProcessResult(
  taskId: string,
  onProgress?: (progress: number) => void
): Promise<ProcessResultResponse> {
  return new Promise((resolve, reject) => {
    const interval = setInterval(async () => {
      try {
        const status = await request('GET', `/images/process/${taskId}/status`);
        
        if (onProgress) {
          onProgress(status.progress || 0);
        }
        
        if (status.status === 'completed') {
          clearInterval(interval);
          const result = await request('GET', `/images/process/${taskId}/result`);
          resolve(result);
        } else if (status.status === 'failed') {
          clearInterval(interval);
          reject(new Error('处理失败'));
        }
      } catch (error) {
        clearInterval(interval);
        reject(error);
      }
    }, 1000); // 每秒查询一次
    
    // 超时处理（30秒）
    setTimeout(() => {
      clearInterval(interval);
      reject(new Error('处理超时'));
    }, 30000);
  });
}
```

### 6. 获取作品列表示例

```typescript
async function getWorks(
  page: number = 1,
  pageSize: number = 20,
  category?: string
): Promise<WorksListResponse> {
  const params = new URLSearchParams();
  params.append('page', page.toString());
  params.append('pageSize', pageSize.toString());
  if (category) {
    params.append('category', category);
  }
  
  return await request('GET', `/works?${params.toString()}`);
}
```

---

## ⚠️ 注意事项

1. **Token 管理**
   - Token 有效期为 2 小时，过期后需要重新登录
   - 建议在应用启动时检查 Token 是否有效
   - Token 应安全存储，不要硬编码在代码中

2. **错误处理**
   - 所有 API 调用都应该进行错误处理
   - 401 错误表示未认证或 Token 过期，需要重新登录
   - 403 错误表示权限不足
   - 429 错误表示请求过于频繁，需要限制请求频率

3. **文件上传**
   - 支持多文件上传
   - 建议限制单文件大小（如 10MB）
   - 批量上传时建议限制总数量

4. **图片处理**
   - 处理是异步的，需要轮询查询结果
   - 建议使用 WebSocket 或 Server-Sent Events 获取实时进度（如果后端支持）
   - 处理时间取决于图片大小和操作复杂度

5. **分页查询**
   - 列表接口都支持分页
   - 建议每页数量不超过 50
   - 实现下拉加载更多时注意避免重复请求

6. **网络请求**
   - 建议添加请求超时设置
   - 实现请求重试机制
   - 在弱网环境下提供友好的错误提示

---

## 📌 更新日志

**文档版本**: 1.0  
**最后更新**: 2024年  
**维护者**: 开发团队

---

## 🔗 相关文档

- [后端项目 README](../lumina-api/README.md)
- [JWT和Redis令牌管理](../lumina-api/docs/JWT和Redis令牌管理.md)
- [微信登录配置](../lumina-api/docs/鸿蒙微信登录.md)
- [API Swagger 文档](http://8.140.227.147:8000/docs)

