#!/usr/bin/env python3
import socket
import sys
import time

def send_udp_message(ip, port, message, count):
    # 创建 UDP 套接字
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    for i in range(count):
        try:
            # 发送数据
            sock.sendto(message.encode(), (ip, port))
            print(f"Sent message: '{message}' to {ip}:{port}")

            # 设置接收超时时间
            sock.settimeout(1)  # 1秒超时
            
            # 接收响应
            response, addr = sock.recvfrom(1024)  # 接收缓冲区大小
            print(f"Received response: '{response.decode()}' from {addr}")

            time.sleep(1)  # 暂停 1 秒钟，以避免发送过快
        except socket.timeout:
            print("No response received within timeout period.")
        except Exception as e:
            print(f"Error sending message: {e}")
            break

    sock.close()

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python send_udp.py <ip> <port> <message> <count>")
        sys.exit(1)

    ip_address = sys.argv[1]
    port_number = int(sys.argv[2])
    message = sys.argv[3]
    repeat_count = int(sys.argv[4])

    send_udp_message(ip_address, port_number, message, repeat_count)
