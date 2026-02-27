# Discourse GetWMX API + Adlist Sidebar Plugin

本插件包含两个核心功能：
1. **GetWMX API** - 通过邮箱查询用户数据的对外 API 接口
2. **Adlist Sidebar** - 可配置的侧边栏广告展示插件

---

## 📡 GetWMX API 接口

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

## 📢 Adlist Sidebar 侧边栏广告

### 功能特性

- ✅ **3 个广告位**：顶部、中部、底部独立配置
- ✅ **灵活位置**：支持左侧或右侧显示
- ✅ **响应式设计**：自动适配桌面/平板，移动端隐藏
- ✅ **后台配置**：通过 Discourse  Admin 设置面板管理
- ✅ **自定义样式**：支持背景色、文字颜色定制
- ✅ **SPA 兼容**：完美支持 Discourse 单页应用导航

### 后台设置

在 Discourse 后台 → 设置 → 插件 → Adlist Sidebar：

| 设置项 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `adlist_sidebar_enabled` | true | 启用/禁用侧边栏广告 |
| `adlist_sidebar_position` | right | 侧边栏位置 (left/right) |
| `adlist_sidebar_ad1_enabled` | true | 启用广告位 1（顶部） |
| `adlist_sidebar_ad1_title` | Featured Product | 广告位 1 标题 |
| `adlist_sidebar_ad1_content` | - | 广告位 1 内容（支持 HTML） |
| `adlist_sidebar_ad1_image_url` | - | 广告位 1 图片 URL |
| `adlist_sidebar_ad1_link_url` | - | 广告位 1 跳转链接 |
| `adlist_sidebar_ad1_link_text` | Learn More | 广告位 1 按钮文字 |
| `adlist_sidebar_ad1_bg_color` | #f8f9fa | 广告位 1 背景色 |
| `adlist_sidebar_ad1_text_color` | #333333 | 广告位 1 文字色 |
| `adlist_sidebar_ad2_*` | - | 广告位 2（中部）配置同上 |
| `adlist_sidebar_ad3_*` | - | 广告位 3（底部）配置同上 |
| `adlist_sidebar_show_on_latest` | true | 在/最新页面显示 |
| `adlist_sidebar_show_on_new` | true | 在/新帖页面显示 |
| `adlist_sidebar_show_on_category` | true | 在分类页面显示 |
| `adlist_sidebar_min_width` | 768 | 最小显示宽度 (px) |

### 显示页面

侧边栏广告可在以下页面显示（可单独配置）：
- `/latest` - 最新话题
- `/new` - 新话题
- `/unread` - 未读话题
- `/top` - 热门话题
- `/c/category` - 分类话题列表

---

## 📝 GetWMX API 使用示例

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

---

## 📤 API 响应格式

### GetWMX 成功响应 (200)

```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "john_doe",
    "name": "John Doe",
    "avatar_template": "/user_avatar/your-discourse.com/john_doe/{size}/1_1.png",
    "active": true,
    "trust_level": 3,
    "topic_count": 15,
    "post_count": 234,
    "created_at": "2024-01-15T08:30:00Z",
    "last_seen_at": "2026-02-26T10:00:00Z"
  },
  "queried_at": "2026-02-26T10:18:00Z"
}
```

### Adlist Sidebar 响应 (200)

```json
{
  "success": true,
  "data": [
    {
      "position": "top",
      "title": "Featured Product",
      "content": "Check out our latest collection!",
      "image_url": "https://example.com/ad-image.jpg",
      "link_url": "https://example.com/shop",
      "link_text": "Shop Now",
      "background_color": "#f8f9fa",
      "text_color": "#333333"
    }
  ],
  "fetched_at": "2026-02-27T04:18:00Z"
}
```

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

## 🎨 Adlist Sidebar 使用示例

### 配置产品推广广告

1. 进入 Admin → Settings → Plugins → Adlist Sidebar
2. 启用 `adlist_sidebar_ad1_enabled`
3. 填写广告内容：
   - **Title**: `🔥 新品上市`
   - **Content**: `2026 春季系列现已上架，限时 8 折优惠！`
   - **Image URL**: `https://your-cdn.com/spring-collection.jpg`
   - **Link URL**: `https://your-shop.com/spring`
   - **Link Text**: `立即选购`
   - **Background Color**: `#fff3cd`
   - **Text Color**: `#856404`

### 配置社区公告广告

```
Title: 📢 社区公告
Content: 欢迎加入我们的 Discourse 社区！请阅读<a href="/t/welcome">新手指南</a>
Link URL: /t/welcome
Link Text: 阅读指南
Background: #d4edda
Text: #155724
```

---

## ⚙️ 配置选项

### GetWMX API 设置

| 设置项 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `getwmx_api_enabled` | true | 启用/禁用 API 接口 |
| `getwmx_api_log_queries` | false | 记录所有查询日志 |
| `getwmx_api_allowed_groups` | trust_level_4,admins | 允许使用 API 的用户组 |

### Adlist Sidebar 设置

详见上文"后台设置"表格。

---

## ⚠️ 安全注意事项

### GetWMX API

1. **API Key 保管**：不要在前端代码中暴露 API Key
2. **速率限制**：建议配置 Nginx 限流，防止滥用
3. **隐私合规**：确保符合 GDPR/隐私法规要求

### Adlist Sidebar

1. **内容审核**：广告内容需符合社区规范
2. **链接安全**：建议使用 HTTPS 链接
3. **性能考虑**：图片广告建议使用 CDN 托管

---

## 🧪 测试

### 测试 GetWMX API

```bash
# 正常查询
curl "http://localhost:3000/getwmx.json?email=admin@example.com" \
  -H "Api-Key: YOUR_KEY" \
  -H "Api-Username: admin"

# 测试广告 API
curl "http://localhost:3000/adlist-sidebar.json"
```

### 测试 Adlist Sidebar

1. 访问 `/latest` 或 `/c/category` 页面
2. 检查右侧（或左侧）是否显示广告侧边栏
3. 调整浏览器宽度，验证响应式隐藏（<768px）
4. 点击广告链接，验证跳转

---

## 📄 许可证

MIT License

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

仓库地址：https://github.com/Hopeail/encrypted-api

---

## 📋 版本历史

### v2.0.0 (2026-02-27)
- ✨ 新增 Adlist Sidebar 侧边栏广告插件
- ✨ 支持 3 个独立广告位配置
- ✨ 支持左右位置切换
- ✨ 响应式设计，移动端自动隐藏
- 🐛 修复 SPA 导航时侧边栏不更新问题

### v1.0.0 (2026-02-26)
- 🎉 初始版本：GetWMX API 接口
