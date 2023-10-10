# -*- coding: utf-8 -*-

import os
from os import path

import requests

from pandora.openai.auth import Auth0

def run():
    proxy = None
    expires_in = 0
    unique_name = 'my share token'
    current_path = os.getcwd()  # 获取当前工作目录路径
    parent_path = os.path.dirname(current_path)  # 获取父目录路径
    current_dir = path.dirname(path.abspath(__file__))
    credentials_file = path.join(current_dir, 'chatgpt_accounts.txt')

    tokens_file = 'chatgpt/chatgpt_token.txt'
	
	# 清空之前的 token 值
    with open(tokens_file, 'w', encoding='utf-8'):
        pass

    with open(credentials_file, 'r', encoding='utf-8') as f:
        credentials = f.read().split('\n')
    credentials = [credential.split(' ', 1) for credential in credentials]
    print(credentials)

    count = 0
    token_keys = []

    # 用于记录是否已经输出过token的标志
    token_output_flag = False

    for credential in credentials:
        progress = '{}/{}'.format(credentials.index(credential) + 1, len(credentials))
        if not credential or len(credential) != 2:
            continue

        count += 1
        username, password = credential[0].strip(), credential[1].strip()
        print('开始登录: {}, {}'.format(username, progress))
        print(password)

        token_info = {
            'token': 'None',
            'share_token': 'None',
        }
        token_keys.append(token_info)

        try:
            token_info['token'] = Auth0(username, password, proxy).auth(False)
            print('登录成功: {}, {}'.format(username, progress))

            # 判断token值长度是否大于100，且未输出过
            if len(token_info['token']) > 100 and not token_output_flag:
                with open(tokens_file, 'w', encoding='utf-8') as f:
                    f.write('{}\n'.format(token_info['token']))
                token_output_flag = True

        except Exception as e:
            err_str = str(e).replace('\n', '').replace('\r', '').strip()
            print('登录失败: {}, {}'.format(username, err_str))
            token_info['token'] = err_str
            continue

        data = {
            'unique_name': unique_name,
            'access_token': token_info['token'],
            'expires_in': expires_in,
        }
        resp = requests.post('https://ai.fakeopen.com/token/register', data=data)
        if resp.status_code == 200:
            token_info['share_token'] = resp.json()['token_key']
            print('共享令牌: {}'.format(token_info['share_token']))
        else:
            err_str = resp.text.replace('\n', '').replace('\r', '').strip()
            print('共享令牌失败: {}'.format(err_str))
            token_info['share_token'] = err_str
            continue

    if not token_output_flag:
        print("未找到长度大于100的token值。")

if __name__ == '__main__':
    run()
