import argparse
import re
import requests
from requests.exceptions import Timeout, RequestException, ConnectionError

def get_access_token(username, password):
    url = "https://chatgpt-token-xiaonuo.vercel.app/getOpenAItoken"

    payload = {
        'username': username,
        'password': password,
        'mfa_code': ''
    }
    files = []

    headers = {
        'authority': 'chatgpt-token-xiaonuo.vercel.app',
        'accept': '*/*',
        'accept-language': 'zh-CN,zh;q=0.9',
        'origin': 'https://chatgpt-token-xiaonuo.vercel.app',
        'referer': 'https://chatgpt-token-xiaonuo.vercel.app/',
        'sec-ch-ua': '"Not/A)Brand";v="99", "Google Chrome";v="115", "Chromium";v="115"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
        'sec-fetch-dest': 'empty',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-origin',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'
    }

    try:
        response = requests.post(url, headers=headers, data=payload, files=files, timeout=10)
        response.raise_for_status()
    except Timeout:
        # print("请求超时，请稍后再试。")
        pass
        return None
    except (ConnectionError, RequestException) as e:
        # print(f"发生错误：{e}")
        pass
        return None

    # 提取响应文本中的Access Token
    access_token = response.text.split("Access Token:", 1)
    # 将列表中的元素连接成单个字符串
    access_token_str = ''.join(access_token).strip()
    return access_token_str

def read_accounts_file(filename):
    accounts_list = []
    try:
        with open(filename, 'r') as file:
            for line in file:
                username, password = line.strip().split()
                accounts_list.append((username, password))
    except FileNotFoundError:
        # print("文件不存在，请检查文件路径是否正确。")
        pass
    except Exception as e:
        # print(f"发生错误：{e}")
        pass
    return accounts_list

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='从服务器中获取Access Token。')
    parser.add_argument('filename', help='包含账号信息的文件名')
    args = parser.parse_args()

    accounts_list = read_accounts_file(args.filename)
    if not accounts_list:
        exit(1)

    access_token_found = False
    for username, password in accounts_list:
        access_token = get_access_token(username, password)
        if access_token and len(access_token) > 100:
            print(access_token)
            access_token_found = True
            break
        else:
            pass
    if not access_token_found:
        pass
