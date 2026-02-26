# -*- coding: utf-8 -*-
"""
NTP 时间同步工具
使用阿里云 NTP 服务器同步系统时间
作者：Hopeail
版本：1.0.0
"""

import sys
import subprocess
import socket
import struct
import time
from datetime import datetime
from typing import Optional, Tuple

# NTP 服务器配置
NTP_SERVERS = [
    "ntp.aliyun.com",
    "ntp1.aliyun.com",
    "ntp2.aliyun.com",
    "time.windows.com",  # 备用
]

# 颜色输出
class Colors:
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'


def print_color(text: str, color: str = Colors.RESET):
    """彩色输出（Windows 10+ 支持 ANSI）"""
    try:
        print(f"{color}{text}{Colors.RESET}")
    except:
        print(text)


def get_ntp_time(server: str, port: int = 123, timeout: int = 5) -> Optional[datetime]:
    """
    从 NTP 服务器获取时间
    
    参考 RFC 5905 NTP 协议
    """
    # NTP 请求数据包（48 字节）
    # 第一个字节：LI(2 位) + VN(3 位) + Mode(3 位) = 0x1B (客户端模式，版本 3)
    ntp_data = b'\x1b' + 47 * b'\0'
    
    try:
        # 创建 UDP  socket
        client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        client.settimeout(timeout)
        
        # 发送请求
        client.sendto(ntp_data, (server, port))
        
        # 接收响应
        response, _ = client.recvfrom(1024)
        
        # 解析 NTP 时间戳（从服务器响应中提取）
        # NTP 时间戳从第 40 字节开始，4 字节整数 + 4 字节小数
        if len(response) < 48:
            return None
            
        ntp_timestamp = struct.unpack('!12I', response)[10]
        
        # NTP 时间起点是 1900-01-01，Unix 时间起点是 1970-01-01
        # 相差 70 年 = 2208988800 秒
        ntp_epoch = 2208988800
        unix_time = ntp_timestamp - ntp_epoch
        
        # 转换为 datetime
        return datetime.fromtimestamp(unix_time)
        
    except socket.timeout:
        print_color(f"  ⚠️  {server} 超时", Colors.YELLOW)
        return None
    except Exception as e:
        print_color(f"  ⚠️  {server} 错误：{str(e)}", Colors.YELLOW)
        return None
    finally:
        client.close()


def get_current_time() -> datetime:
    """获取当前系统时间"""
    return datetime.now()


def get_time_difference(ntp_time: datetime, local_time: datetime) -> Tuple[float, str]:
    """计算时间差"""
    diff = (ntp_time - local_time).total_seconds()
    
    if abs(diff) < 1:
        return diff, "无需同步"
    elif abs(diff) < 60:
        return diff, f"{abs(diff):.1f}秒"
    elif abs(diff) < 3600:
        return diff, f"{abs(diff)/60:.1f}分钟"
    else:
        return diff, f"{abs(diff)/3600:.1f}小时"


def sync_windows_time(ntp_time: datetime) -> bool:
    """
    同步 Windows 系统时间
    需要管理员权限
    """
    try:
        # 方法 1: 使用 net time 命令（需要管理员）
        time_str = ntp_time.strftime("%Y-%m-%d %H:%M:%S")
        
        print_color(f"\n🔄 正在设置系统时间为：{time_str}", Colors.BLUE)
        
        # 使用 PowerShell 设置时间（需要管理员权限）
        cmd = f'powershell -Command "Set-Date -Date \'{time_str}\'"'
        
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode == 0:
            print_color("✅ 时间同步成功！", Colors.GREEN)
            return True
        else:
            print_color(f"❌ 设置时间失败：{result.stderr}", Colors.RED)
            return False
            
    except subprocess.TimeoutExpired:
        print_color("❌ 设置时间超时", Colors.RED)
        return False
    except Exception as e:
        print_color(f"❌ 错误：{str(e)}", Colors.RED)
        return False


def check_admin_privileges() -> bool:
    """检查是否有管理员权限"""
    try:
        return subprocess.run(
            'net session >nul 2>&1',
            shell=True,
            capture_output=True
        ).returncode == 0
    except:
        return False


def request_admin_privileges():
    """请求管理员权限（UAC 提权）"""
    print_color("\n⚠️  需要管理员权限才能同步系统时间", Colors.YELLOW)
    print_color("🔄 请求管理员权限...", Colors.BLUE)
    
    try:
        # 使用 PowerShell 请求提权并重新运行
        script = sys.executable if getattr(sys, 'frozen', False) else sys.executable
        params = ' '.join(sys.argv)
        
        cmd = f'start powershell -Verb RunAs "{script}" {params}'
        subprocess.Popen(cmd, shell=True)
        
        sys.exit(0)
    except Exception as e:
        print_color(f"❌ 提权失败：{str(e)}", Colors.RED)
        print_color("\n请右键点击程序 → 以管理员身份运行", Colors.YELLOW)
        input("\n按回车键退出...")
        sys.exit(1)


def sync_time():
    """主同步流程"""
    print_color("\n" + "="*50, Colors.BOLD)
    print_color("🕐 NTP 时间同步工具 v1.0.0", Colors.BOLD + Colors.BLUE)
    print_color("="*50, Colors.BOLD)
    
    # 检查管理员权限
    if not check_admin_privileges():
        request_admin_privileges()
    
    # 显示当前本地时间
    local_time = get_current_time()
    print_color(f"\n📍 当前本地时间：{local_time.strftime('%Y-%m-%d %H:%M:%S')}", Colors.WHITE)
    
    # 尝试多个 NTP 服务器
    ntp_time = None
    used_server = None
    
    print_color("\n🌐 正在连接 NTP 服务器...", Colors.BLUE)
    
    for server in NTP_SERVERS:
        print_color(f"  → 尝试 {server}...", Colors.WHITE)
        ntp_time = get_ntp_time(server)
        
        if ntp_time:
            used_server = server
            print_color(f"  ✅ {server} 响应成功", Colors.GREEN)
            break
    
    if not ntp_time:
        print_color("\n❌ 所有 NTP 服务器都无法连接", Colors.RED)
        print_color("请检查网络连接后重试", Colors.YELLOW)
        input("\n按回车键退出...")
        return False
    
    # 显示 NTP 时间
    print_color(f"\n🌐 NTP 服务器时间 ({used_server}): {ntp_time.strftime('%Y-%m-%d %H:%M:%S')}", Colors.GREEN)
    
    # 计算时间差
    diff, diff_str = get_time_difference(ntp_time, local_time)
    
    print_color(f"\n⏱️  时间差：{diff_str} ({'+' if diff > 0 else ''}{diff:.1f}秒)", 
                Colors.YELLOW if abs(diff) > 1 else Colors.GREEN)
    
    if abs(diff) < 1:
        print_color("\n✅ 时间已同步，无需调整", Colors.GREEN)
        input("\n按回车键退出...")
        return True
    
    # 确认同步
    print_color(f"\n🔄 即将同步系统时间（差异：{diff_str}）", Colors.YELLOW)
    
    # 执行同步
    success = sync_windows_time(ntp_time)
    
    if success:
        # 验证同步结果
        new_local_time = get_current_time()
        new_diff = (ntp_time - new_local_time).total_seconds()
        print_color(f"\n✓ 同步后时间：{new_local_time.strftime('%Y-%m-%d %H:%M:%S')}", Colors.GREEN)
        print_color(f"✓ 剩余误差：{abs(new_diff):.1f}秒", Colors.GREEN)
    
    input("\n按回车键退出...")
    return success


def main():
    """入口函数"""
    try:
        # 启用 Windows ANSI 颜色支持
        if sys.platform == 'win32':
            try:
                import ctypes
                kernel32 = ctypes.windll.kernel32
                kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 7)
            except:
                pass
        
        sync_time()
        
    except KeyboardInterrupt:
        print_color("\n\n⚠️  用户中断", Colors.YELLOW)
        input("按回车键退出...")
        sys.exit(0)
    except Exception as e:
        print_color(f"\n❌ 未知错误：{str(e)}", Colors.RED)
        input("\n按回车键退出...")
        sys.exit(1)


if __name__ == "__main__":
    main()
