# 🕐 NTP 时间同步工具

一键同步 Windows 系统时间到阿里云 NTP 服务器。

---

## 📥 下载

### 方式 1：直接下载 EXE（推荐）

从 GitHub Releases 下载已编译的 EXE 文件：
https://github.com/Hopeail/encrypted-api/releases

### 方式 2：自行编译

```bash
# 1. 克隆仓库
git clone https://github.com/Hopeail/encrypted-api.git
cd encrypted-api/ntp-sync-tool

# 2. 运行打包脚本（Windows）
build.bat

# 或使用 PowerShell
.\build.ps1
```

---

## 🚀 使用方法

### 方法 A：图形界面（推荐）

1. **右键点击** `NTP 时间同步.exe`
2. 选择 **"以管理员身份运行"**
3. 程序自动同步时间

### 方法 B：命令行

```cmd
# 以管理员身份打开 CMD 或 PowerShell
NTP 时间同步.exe
```

---

## ⚙️ 功能特性

| 功能 | 说明 |
| :--- | :--- |
| **多服务器支持** | 自动尝试多个 NTP 服务器，确保可靠性 |
| **管理员权限** | 自动检测并请求 UAC 提权 |
| **彩色输出** | 清晰的进度和状态显示 |
| **时间验证** | 同步后自动验证时间准确性 |
| **备用服务器** | 阿里云 NTP 不可用时自动切换 |

---

## 🌐 NTP 服务器列表

| 优先级 | 服务器 | 位置 |
| :--- | :--- | :--- |
| 1 | ntp.aliyun.com | 阿里云主服务器 |
| 2 | ntp1.aliyun.com | 阿里云备用 1 |
| 3 | ntp2.aliyun.com | 阿里云备用 2 |
| 4 | time.windows.com | 微软备用 |

---

## ⚠️ 注意事项

1. **需要管理员权限**：同步系统时间需要管理员权限
2. **网络连接**：确保电脑可以访问互联网
3. **防火墙**：确保 UDP 123 端口未被阻止
4. **虚拟机**：虚拟机可能需要先同步宿主机时间

---

## 🔧 故障排除

### 问题 1：提示"需要管理员权限"

**解决**：右键点击程序 → 选择"以管理员身份运行"

### 问题 2：所有 NTP 服务器超时

**解决**：
1. 检查网络连接
2. 检查防火墙设置（UDP 123 端口）
3. 尝试更换网络环境

### 问题 3：同步后时间仍然不准

**解决**：
1. 再次运行同步程序
2. 检查主板 CMOS 电池是否老化
3. 在 Windows 设置中启用"自动设置时间"

---

## 📁 文件说明

```
ntp-sync-tool/
├── ntp_sync.py          # 主程序源代码
├── build.bat            # Windows 打包脚本
├── build.ps1            # PowerShell 打包脚本
├── README.md            # 说明文档
└── dist/
    └── NTP 时间同步.exe  # 编译后的可执行文件
```

---

## 🛠️ 技术细节

- **开发语言**：Python 3.8+
- **打包工具**：PyInstaller
- **协议**：NTP (RFC 5905)
- **端口**：UDP 123

---

## 📄 许可证

MIT License

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

仓库地址：https://github.com/Hopeail/encrypted-api

---

## 📞 支持

如有问题，请通过 GitHub Issues 反馈。
