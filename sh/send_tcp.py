#!/usr/bin/env python3
import socket
import sys
import time

def send_tcp_message(ip, port, message, count):
    # 创建 TCP 套接字
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    try:
        # 连接到服务器
        sock.connect((ip, port))
        for i in range(count):
            try:
                # 发送数据
                sock.sendall(message.encode())
                print(f"Sent message: '{message}' to {ip}:{port}")

                # 设置接收超时时间，避免一直等待
                sock.settimeout(5)  # 增加超时时间

                # 接收响应
                response = sock.recv(1024)  # 接收缓冲区大小
                print(f"Received response: '{response.decode()}'")

                time.sleep(1)  # 暂停 1 秒钟，以避免发送过快
            except socket.timeout:
                print("No response received within timeout period.")
                break  # 如果超时则退出
            except Exception as e:
                print(f"Error sending message: {e}")
                break
    except Exception as e:
        print(f"Error connecting to server: {e}")
    finally:
        sock.close()

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python send_tcp.py <ip> <port> <message> <count>")
        sys.exit(1)

    ip_address = sys.argv[1]
    port_number = int(sys.argv[2])
    message = sys.argv[3]
    repeat_count = int(sys.argv[4])

    send_tcp_message(ip_address, port_number, message, repeat_count)
