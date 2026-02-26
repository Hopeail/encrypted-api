# Discourse GetWMX API Plugin

通过邮箱查询用户数据的对外 API 接口。

---

## 📡 API 接口

### `GET /getwmx.json`

通过用户邮箱查询用户公开数据。

#### 请求参数

| 参数 | 类型 | 必填 | 说明 |
| :--- | :--- | :--- | :--- |
| `email` | string | 是 | 用户邮箱地址 |

#### 请求头

| 头 | 值 | 说明 |
| :--- | :--- | :--- |
| `Api-Key` | string | 是 | Discourse API Key |
| `Api-Username` | string | 是 | 管理员用户名 |

---

## 📝 使用示例

### cURL 示例

```bash
curl -X GET "https://your-discourse.com/getwmx.json?email=user@example.com" \
  -H "Api-Key: YOUR_API_KEY" \
  -H "Api-Username: admin"
```

### JavaScript 示例

```javascript
const response = await fetch('https://your-discourse.com/getwmx.json?email=user@example.com', {
  method: 'GET',
  headers: {
    'Api-Key': 'YOUR_API_KEY',
    'Api-Username': 'admin'
  }
});

const data = await response.json();
console.log(data);
```

### Python 示例

```python
import requests

url = "https://your-discourse.com/getwmx.json"
params = {"email": "user@example.com"}
headers = {
    "Api-Key": "YOUR_API_KEY",
    "Api-Username": "admin"
}

response = requests.get(url, params=params, headers=headers)
data = response.json()
print(data)
```

---

## 📤 响应格式

### 成功响应 (200)

```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "john_doe",
    "name": "John Doe",
    "avatar_template": "/user_avatar/your-discourse.com/john_doe/{size}/1_1.png",
    "active": true,
    "approved": true,
    "suspended": false,
    "suspended_till": null,
    "trust_level": 3,
    "moderator": false,
    "admin": false,
    "staff": false,
    "topic_count": 15,
    "post_count": 234,
    "badge_count": 8,
    "like_count": 567,
    "like_given_count": 890,
    "created_at": "2024-01-15T08:30:00Z",
    "last_seen_at": "2026-02-26T10:00:00Z",
    "last_posted_at": "2026-02-25T15:30:00Z",
    "bio_raw": "Hello, I'm John!",
    "location": "San Francisco, CA",
    "website": "https://johndoe.com",
    "twitter_name": "johndoe",
    "groups": ["trust_level_3", "bloggers"]
  },
  "queried_at": "2026-02-26T10:18:00Z"
}
```

### 错误响应

#### 缺少邮箱参数 (400)

```json
{
  "success": false,
  "error": "Email parameter is required",
  "error_code": "MISSING_EMAIL"
}
```

#### 邮箱格式错误 (400)

```json
{
  "success": false,
  "error": "Invalid email format",
  "error_code": "INVALID_EMAIL"
}
```

#### 用户不存在 (404)

```json
{
  "success": false,
  "error": "User not found",
  "error_code": "USER_NOT_FOUND"
}
```

#### 访问被拒绝 (403)

```json
{
  "success": false,
  "error": "Access denied - user profile is private",
  "error_code": "ACCESS_DENIED"
}
```

#### 未授权 (401)

```json
{
  "success": false,
  "error": "Valid API key required",
  "error_code": "UNAUTHORIZED"
}
```

---

## 🔐 权限说明

### API Key 要求

- **必须** 使用有效的 Discourse API Key
- **必须** 指定 API Username（建议管理员）
- API Key 可在 admin 后台生成：`/admin/api/key`

### 用户数据访问规则

| 查询者 | 可查询范围 |
| :--- | :--- |
| **管理员** | 所有用户（包括私有资料） |
| **普通用户** | 仅公开用户（public_user = true） |

### 数据脱敏

以下敏感字段**不会**返回：
- ❌ `email`（邮箱本身）
- ❌ `password`（密码）
- ❌ `ip_address`（IP 地址）
- ❌ `registration_ip_address`（注册 IP）
- ❌ `last_ip_address`（最后登录 IP）
- ❌ `otp_secret`（双因素密钥）
- ❌ `second_factor_secret`（备用验证密钥）

---

## 🚀 安装步骤

### 方法 A：Git 克隆

```bash
cd /var/discourse/shared/standalone/plugins
git clone https://github.com/Hopeail/encrypted-api.git discourse-getwmx-api
cd /var/discourse
./launcher rebuild app
```

### 方法 B：手动复制

```bash
# 1. 下载插件代码
# 2. 复制到插件目录
cp -r discourse-getwmx-api /var/discourse/shared/standalone/plugins/

# 3. 重建
cd /var/discourse
./launcher rebuild app
```

---

## ⚙️ 配置选项

在 Discourse 后台 → 设置 → 插件 → GetWMX API：

| 设置项 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `getwmx_api_enabled` | true | 启用/禁用 API 接口 |
| `getwmx_api_log_queries` | false | 记录所有查询日志（审计用） |
| `getwmx_api_allowed_groups` | trust_level_4,admins | 允许使用 API 的用户组 |

---

## 📊 错误代码对照表

| 错误代码 | HTTP 状态码 | 说明 |
| :--- | :--- | :--- |
| `MISSING_EMAIL` | 400 | 缺少邮箱参数 |
| `INVALID_EMAIL` | 400 | 邮箱格式错误 |
| `USER_NOT_FOUND` | 404 | 用户不存在 |
| `ACCESS_DENIED` | 403 | 访问被拒绝 |
| `UNAUTHORIZED` | 401 | 未授权（API Key 无效） |
| `AUTH_ERROR` | 401 | 认证失败 |

---

## ⚠️ 安全注意事项

1. **API Key 保管**：不要在前端代码中暴露 API Key
2. **速率限制**：建议配置 Nginx 限流，防止滥用
3. **日志审计**：开启 `getwmx_api_log_queries` 记录查询历史
4. **隐私合规**：确保符合 GDPR/隐私法规要求

---

## 🧪 测试

### 单元测试

```bash
cd /var/discourse
bundle exec rspec plugins/discourse-getwmx-api/spec/requests/getwmx_api_spec.rb
```

### 手动测试

```bash
# 1. 测试正常查询
curl "http://localhost:3000/getwmx.json?email=admin@example.com" \
  -H "Api-Key: YOUR_KEY" \
  -H "Api-Username: admin"

# 2. 测试缺少邮箱
curl "http://localhost:3000/getwmx.json" \
  -H "Api-Key: YOUR_KEY" \
  -H "Api-Username: admin"

# 3. 测试无效邮箱
curl "http://localhost:3000/getwmx.json?email=invalid" \
  -H "Api-Key: YOUR_KEY" \
  -H "Api-Username: admin"

# 4. 测试用户不存在
curl "http://localhost:3000/getwmx.json?email=notfound@example.com" \
  -H "Api-Key: YOUR_KEY" \
  -H "Api-Username: admin"
```

---

## 📄 许可证

MIT License

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

仓库地址：https://github.com/Hopeail/encrypted-api
