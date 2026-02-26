# Discourse Encrypted API Plugin

为 Discourse 论坛添加 3 个带 RSA 非对称加密的 API 接口。

## 🔐 功能特性

- **RSA-2048 非对称加密**：所有 API 响应均使用 RSA-OAEP-SHA256 算法加密
- **数字签名**：每个响应附带 SHA256 签名，确保数据完整性
- **参考现有接口**：完全参考 Discourse 原生 API 设计
- **管理员密钥管理**：后台一键生成/轮换 RSA 密钥对

## 📡 API 接口列表

| 接口 | 方法 | 权限 | 说明 |
| :--- | :--- | :--- | :--- |
| `/encrypted/session/current` | GET | 登录用户 | 当前会话信息 |
| `/encrypted/user/:username/summary` | GET | 登录用户 | 用户摘要信息 |
| `/encrypted/session/:username` | GET | 登录用户 | 会话状态验证 |
| `/admin/encrypted/keys/generate` | POST | 管理员 | 生成 RSA 密钥对 |
| `/admin/encrypted/keys/public` | GET | 登录用户 | 获取公钥 |

## 🚀 安装步骤

### 1. 克隆插件到 Discourse 插件目录

```bash
cd /var/discourse
git clone https://github.com/yourusername/discourse-encrypted-api.git shared/discourse-encrypted-api
```

### 2. 重建 Discourse 容器

```bash
cd /var/discourse/containers
./discourse-setup app rebuild
```

### 3. 生成 RSA 密钥对

登录 Discourse 管理员后台 → 设置 → 插件 → Encrypted API → 点击"Generate RSA Keys"

或使用 API：

```bash
curl -X POST "https://your-discourse.com/admin/encrypted/keys/generate.json" \
  -H "Api-Key: YOUR_API_KEY" \
  -H "Api-Username: admin"
```

## 📖 使用示例

### 客户端解密流程

```javascript
// 1. 获取公钥
const publicKeyRes = await fetch('/admin/encrypted/keys/public.json', {
  headers: {
    'Api-Key': 'YOUR_API_KEY',
    'Api-Username': 'your-username'
  }
});
const { public_key } = await publicKeyRes.json();

// 2. 调用加密 API
const apiRes = await fetch('/encrypted/session/current.json', {
  headers: {
    'Api-Key': 'YOUR_API_KEY',
    'Api-Username': 'your-username'
  }
});
const { encrypted, signature, timestamp } = await apiRes.json();

// 3. 使用私钥解密（服务端）
const decrypted = rsaDecrypt(encrypted, privateKey);
console.log(decrypted.data.current_user);
```

### Ruby 解密示例

```ruby
require 'openssl'
require 'base64'
require 'json'

def decrypt_response(encrypted_base64, signature_base64, public_key_pem, private_key_pem)
  # 验证签名
  public_key = OpenSSL::PKey::RSA.new(public_key_pem)
  private_key = OpenSSL::PKey::RSA.new(private_key_pem)
  
  payload_json = Base64.strict_decode64(encrypted_base64)
  payload_decrypted = private_key.private_decrypt(payload_json)
  payload = JSON.parse(payload_decrypted)
  
  signature = Base64.strict_decode64(signature_base64)
  valid = public_key.verify(OpenSSL::Digest::SHA256.new, signature, payload.to_json)
  
  raise 'Invalid signature' unless valid
  
  payload
end
```

## 🔑 响应格式

所有加密接口返回统一格式：

```json
{
  "encrypted": "base64-encoded-encrypted-data",
  "signature": "base64-encoded-signature",
  "algorithm": "RSA-OAEP-SHA256",
  "timestamp": "2026-02-26T05:00:00Z"
}
```

解密后数据结构：

```json
{
  "data": { ... },
  "timestamp": "2026-02-26T05:00:00Z"
}
```

## 🧪 运行测试

```bash
cd /var/discourse
bundle exec rspec plugins/discourse-encrypted-api/spec/requests/encrypted_api_spec.rb
```

## ⚠️ 安全注意事项

1. **私钥保管**：私钥存储在站点设置中，确保数据库加密
2. **密钥轮换**：建议每 90 天轮换一次密钥对
3. **HTTPS 强制**：生产环境必须启用 HTTPS
4. **访问控制**：所有接口均需登录，管理员接口需 admin 权限

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！
